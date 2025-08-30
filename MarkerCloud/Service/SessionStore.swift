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
    @Published var authUser: User?
    @Published var appUser: AppUser?
    @Published var isLoading = true

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?

    init() { start() }

    func start() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.authUser = user
            self.bindUserDoc(for: user?.uid)
        }
    }

    private func bindUserDoc(for uid: String?) {
        userListener?.remove(); userListener = nil
        appUser = nil
        isLoading = false

        guard let uid else { return }

        userListener = AppUser.docRef(uid: uid).addSnapshotListener { [weak self] snap, err in
            Task { @MainActor in
                if let err = err {
                    print("user doc listen error: \(err)")
                    return
                }
                do {
                    self?.appUser = try snap?.data(as: AppUser.self)
                } catch {
                    print("decode error: \(error)")
                }
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        bindUserDoc(for: nil)
    }

    deinit {
        if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) }
        userListener?.remove()
    }
}
