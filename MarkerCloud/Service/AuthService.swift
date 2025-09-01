//
//  AuthService.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit
import FirebaseCore
import GoogleSignIn
import AuthenticationServices

// 사용자 인증 서비스
final class AuthService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func signInWithGoogle(presenting vc: UIViewController?, onComplete: @escaping (FirebaseAuth.User?) -> Void) {
        // 프로젠팅 VC가 없으면 진행 불가
        guard let vc = vc else {
            self.errorMessage = "화면 컨트롤러를 찾을 수 없어요."
            onComplete(nil)
            return
        }
        //UI 상태 초기화
        isLoading = true
        errorMessage = nil

        //구글 로그인 플로우 시작
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, err in
            //사용자 취소 / 네트워크,설정 문제 오류
            if let err = err {
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = err.localizedDescription
                    print("[AuthService] GoogleSignIn error:", err.localizedDescription)
                }
                onComplete(nil)
                return
            }

            //구글 토큰 확보 - firebase auth로 넘겨서 연동할때 필요
            guard let result = result,
                  let idToken = result.user.idToken?.tokenString else {
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = "Google 인증 토큰을 가져오지 못했습니다."
                    print("[AuthService] Missing Google idToken")
                }
                onComplete(nil)
                return
            }

            //액세스 토큰을 사용하여 firebase credential 생성
            //firebase credential : 이 사용자가 누구인지 증명하는 티켓
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            //firbase auth 로그인
            Auth.auth().signIn(with: credential) { authResult, err in
                if let err = err {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = err.localizedDescription
                        print("[AuthService] Firebase signIn error:", err.localizedDescription)
                    }
                    onComplete(nil)
                    return
                }

                //firebase에서 최종 사용자 객체 획득
                guard let fbUser = authResult?.user else {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                        print("[AuthService] Firebase user is nil")
                    }
                    onComplete(nil)
                    return
                }

                // Firestore upsert (최초 생성 시에만 createdAt 세팅)
                let userRef = self.db.collection("users").document(fbUser.uid)

                Task {
                    do {
                        //문서 존재 여부 판단
                        let snap = try await userRef.getDocument()
                        //공통필드(항상갱신)
                        var data: [String: Any] = [
                            "id": fbUser.uid,
                            "email": fbUser.email ?? result.user.profile?.email ?? "",
                            "userName": fbUser.displayName ?? result.user.profile?.name ?? "",
                            "provider": "google",
                            "updatedAt": FieldValue.serverTimestamp()
                        ]
                        //문서가 없으면 최초 생성
                        if !snap.exists {
                            data["createdAt"] = FieldValue.serverTimestamp()
                        }

                        //기존 필드 유지, 덮어쓸 필드만 갱신
                        try await userRef.setData(data, merge: true)

                        await MainActor.run {
                            self.isLoading = false
                            print("[AuthService] upsert user doc done. uid=\(fbUser.uid), createdAt set? \(!snap.exists)")
                        }
                        //상위로 성공 콜팩
                        onComplete(fbUser)
                    } catch {
                        await MainActor.run {
                            self.isLoading = false
                            self.errorMessage = "Firestore 저장 오류: \(error.localizedDescription)"
                            print("[AuthService] upsert error:", error.localizedDescription)
                        }
                        onComplete(fbUser)
                    }
                }
            }
        }
    }
}
