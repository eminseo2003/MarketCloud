//
//  SessionStore.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class SessionStore: ObservableObject {

    enum Phase {
        case loading
        case signedOut
        case needsProfile
        case signedIn(AppUser)
    }

    @Published var phase: Phase = .loading
    @Published var authUser: User?
    @Published var appUser: AppUser?
    @Published var isLoading = true

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    init() { start() }

    func start() {
        isLoading = true
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                await self?.handleAuthChange(user)
            }
        }
    }

    private func stopUserListener() {
        userListener?.remove()
        userListener = nil
    }

    private func resetStateForSignOut() {
        stopUserListener()
        authUser = nil
        appUser = nil
        isLoading = false
        phase = .signedOut
    }

    private func listenUserDoc(uid: String) {
        stopUserListener()
        appUser = nil
        isLoading = true
        phase = .loading
        
        print("[SessionStore] listenUserDoc(uid=\(uid))")

        userListener = AppUser.docRef(uid: uid).addSnapshotListener { [weak self] snap, err in
            Task { @MainActor in
                guard let self else { return }

                if let err = err {
                    print("user doc listen error:", err)
                    self.isLoading = false
                    self.phase = .needsProfile
                    return
                }
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

                do {
                    let user = try snap.data(as: AppUser.self)
                    self.appUser = user
                    self.isLoading = false
                    self.phase = .signedIn(user)
                    let fbUid = self.authUser?.uid ?? "nil"
                    print("[SessionStore] AppUser loaded → AppUser.id=\(user.id) / Firebase uid=\(fbUid)")
                } catch {
                    print("decode error:", error)
                    self.appUser = nil
                    self.isLoading = false
                    self.phase = .needsProfile
                }
            }
        }
    }

    private func handleAuthChange(_ user: User?) async {
        guard let user else {
            resetStateForSignOut()
            return
        }

        await refreshAuthUser(user)

        if let current = Auth.auth().currentUser {
            self.authUser = current
            listenUserDoc(uid: current.uid)
        } else {
            resetStateForSignOut()
        }
    }

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

    func signOut() {
        try? Auth.auth().signOut()
        resetStateForSignOut()
    }

    deinit {
        if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) }
        userListener?.remove()
    }
}
