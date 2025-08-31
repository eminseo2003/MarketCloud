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

final class AuthService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func signInWithGoogle(presenting vc: UIViewController?, onComplete: @escaping (FirebaseAuth.User?) -> Void) {
        guard let vc = vc else {
            self.errorMessage = "화면 컨트롤러를 찾을 수 없어요."
            onComplete(nil)
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, err in
            if let err = err {
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = err.localizedDescription
                    print("[AuthService] GoogleSignIn error:", err.localizedDescription)
                }
                onComplete(nil)
                return
            }

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

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

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
                        let snap = try await userRef.getDocument()

                        var data: [String: Any] = [
                            "id": fbUser.uid,
                            "email": fbUser.email ?? result.user.profile?.email ?? "",
                            "userName": fbUser.displayName ?? result.user.profile?.name ?? "",
                            "provider": "google",
                            "updatedAt": FieldValue.serverTimestamp()
                        ]
                        if !snap.exists {
                            data["createdAt"] = FieldValue.serverTimestamp()
                        }

                        try await userRef.setData(data, merge: true)

                        await MainActor.run {
                            self.isLoading = false
                            print("[AuthService] upsert user doc done. uid=\(fbUser.uid), createdAt set? \(!snap.exists)")
                        }
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
