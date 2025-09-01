//
//  SessionStore.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

//앱 전역의 인증/프로필 상태를 관찰하고 라우팅 근거(phase)를 제공하는 스토어
@MainActor
final class SessionStore: ObservableObject {

    //로그인 전반 상태 머신
    enum Phase {
        case loading
        case signedOut
        case needsProfile
        case signedIn(AppUser)
    }

    @Published var phase: Phase = .loading //현재 상태
    @Published var authUser: User? //firebase auth의 현재 사용자
    @Published var appUser: AppUser? //firestore에 저장된 앱 도메인 사용자
    @Published var isLoading = true

    private var authHandle: AuthStateDidChangeListenerHandle? //firebase auth 상태 변경 리스너
    private var userListener: ListenerRegistration? //firesore users/{uid} 스냅샷 리스너

    init() { start() }

    //firebaseauth가 로그인/로그아웃/토큰갱신 등으로 사용자 객체가 바뀌면 콜백 호출
    func start() {
        isLoading = true
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                await self?.handleAuthChange(user)
            }
        }
    }

    //리스너를 해제(로그아웃/재로그인 전 환기)
    private func stopUserListener() {
        userListener?.remove()
        userListener = nil
    }

    //로그아웃 시 상태 초기화 / 모든 캐시 상태 초기화
    private func resetStateForSignOut() {
        stopUserListener()
        authUser = nil
        appUser = nil
        isLoading = false
        phase = .signedOut
    }

    //users 문서를 실시간으로 구독
    private func listenUserDoc(uid: String) {
        stopUserListener()
        appUser = nil
        isLoading = true
        phase = .loading
        
        print("[SessionStore] listenUserDoc(uid=\(uid))")

        userListener = AppUser.docRef(uid: uid).addSnapshotListener { [weak self] snap, err in
            Task { @MainActor in
                guard let self else { return }

                //스냅샷 수신 에러 -> 프로필 생성 필요 상태로 유도
                if let err = err {
                    print("user doc listen error:", err)
                    self.isLoading = false
                    self.phase = .needsProfile
                    return
                }
                //스냅샷 자체가 없거나 문서가 존재하지 않으면 프로필 생성
                guard let snap = snap else {
                    self.isLoading = false
                    self.phase = .needsProfile
                    return
                }
                guard snap.exists else {
                    self.isLoading = false
                    self.appUser = nil
                    self.phase = .needsProfile
                    return
                }

                //문서 존대 -> AppUser 디코딩 시도
                do {
                    let user = try snap.data(as: AppUser.self)
                    self.appUser = user
                    self.isLoading = false
                    self.phase = .signedIn(user)
                    let appId = user.id ?? "nil"
                    let fbUid = self.authUser?.uid ?? "nil"
                    print("[SessionStore] AppUser loaded → AppUser.id=\(appId) / Firebase uid=\(fbUid)")

                } catch {
                    print("decode error:", error)
                    self.appUser = nil
                    self.isLoading = false
                    self.phase = .needsProfile
                }
            }
        }
    }

    //auth 상태 변경 처리
    private func handleAuthChange(_ user: User?) async {
        //로그아웃/토큰만료/삭제
        guard let user else {
            resetStateForSignOut()
            return
        }

        //사용자 세션 최신화
        await refreshAuthUser(user)

        //현재 사용자 다시 읽어 세팅
        if let current = Auth.auth().currentUser {
            self.authUser = current
            //유저 프로필 문서 실시간 구독 시작
            listenUserDoc(uid: current.uid)
        } else {
            resetStateForSignOut()
        }
    }

    //firebase user 갱신
    private func refreshAuthUser(_ user: User) async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            user.reload { error in
                if let ns = error as NSError? {
                    if ns.code == AuthErrorCode.userNotFound.rawValue ||
                       ns.code == AuthErrorCode.userDisabled.rawValue ||
                       ns.code == AuthErrorCode.userTokenExpired.rawValue {
                        try? Auth.auth().signOut()
                    }
                }
                cont.resume()
            }
        }
    }

    //로그아웃 - firebaseauth 세션을 종료하고 상태를 초기화
    func signOut() {
        try? Auth.auth().signOut()
        resetStateForSignOut()
    }

    //리스너 정리
    deinit {
        if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) }
        userListener?.remove()
    }
}
