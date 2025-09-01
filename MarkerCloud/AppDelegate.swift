//
//  AppDelegate.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/30/25.
//

import FirebaseCore
import GoogleSignIn
import FirebaseAuth

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("Firebase configured")
    } else {
      print("Firebase already configured")
    }

    if let clientID = FirebaseApp.app()?.options.clientID {
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
      print("GoogleSignIn configured")
    }
    return true
  }

  // Kakao(OIDC)/Google 콜백 전달
  func application(_ app: UIApplication, open url: URL,
                   options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if Auth.auth().canHandle(url) { print("[Auth] handled:", url); return true }
    if GIDSignIn.sharedInstance.handle(url) { print("[Google] handled:", url); return true }
    return false
  }
}
