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
        
        // GoogleSignIn: clientID는 Firebase에서 가져오면 안전
        let clientID = FirebaseApp.app()?.options.clientID
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, err in
            if let err = err {
                self.isLoading = false
                self.errorMessage = err.localizedDescription
                onComplete(nil)
                return
            }
            guard let result = result,
                  let idToken = result.user.idToken?.tokenString else {
                self.isLoading = false
                self.errorMessage = "Google 인증 토큰을 가져오지 못했습니다."
                onComplete(nil)
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { authResult, err in
                if let err = err {
                    self.isLoading = false
                    self.errorMessage = err.localizedDescription
                    onComplete(nil)
                    return
                }
                
                guard let fbUser = authResult?.user else {
                    self.isLoading = false
                    self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                    onComplete(nil)
                    return
                }
                
                // Firestore upsert
                let data: [String: Any] = [
                    "id": fbUser.uid,
                    "email": fbUser.email ?? result.user.profile?.email ?? "",
                    "userName": fbUser.displayName ?? result.user.profile?.name ?? "",
                    "provider": "google",
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                self.db.collection("users").document(fbUser.uid).setData(data, merge: true) { fsErr in
                    self.isLoading = false
                    if let fsErr = fsErr {
                        self.errorMessage = "Firestore 저장 오류: \(fsErr.localizedDescription)"
                    }
                    onComplete(fbUser)
                }
            }
        }
    }
}
