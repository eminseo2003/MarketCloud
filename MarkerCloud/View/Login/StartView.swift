//
//  ContentView.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

import SwiftUI
import UIKit

struct StartView: View {
    @Binding var currentUserID: Int
    @StateObject private var auth = AuthService()
    @State private var route: Route? = nil
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Image("loginBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Text("동대문구 전통시장을 한 눈에")
                        .foregroundColor(Color(hex: "#4A4A4A"))
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 50)
                    VStack(spacing: 16) {
                        Spacer()
                        Button(action: {
                            
                        }) {
                            ZStack {
                                Text("카카오로 시작하기")
                                    .foregroundColor(.primary)
                                HStack {
                                    Image("kakaologo")
                                    Spacer()
                                }.padding()
                            }
                        }.buttonStyle(OutlineCTA())
                        Button(action: {
                            let vc = UIApplication.topViewController()
                            auth.signInWithGoogle(presenting: vc) { user in
                                guard user != nil else { return }
                                //route = .login
                            }
                        }) {
                            ZStack {
                                Text("구글로 시작하기")
                                    .foregroundColor(.primary)
                                HStack {
                                    Image("googlelogo")
                                    Spacer()
                                }.padding()
                            }
                        }.buttonStyle(OutlineCTA())
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 100)
                }
            }
            .overlay(alignment: .bottom) {
                if auth.isLoading {
                    ProgressView().padding(.bottom, 40)
                }
            }
            .alert("로그인 오류", isPresented: .constant(auth.errorMessage != nil)) {
                Button("확인") { auth.errorMessage = nil }
            } message: {
                Text(auth.errorMessage ?? "")
            }
            .navigationDestination(item: $route) { route in
                if route == .login {
                    LoginView(currentUserID: $currentUserID)
                } else if route == .join {
                    JoinView()
                }
            }
        }
        
    }
}


extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return topViewController(base: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return topViewController(base: presented)
            }
            return base
        }
}


extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (예: #AABBCC)
            (r, g, b, a) = (int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff, 255)
        case 8: // RGBA (예: #AABBCCDD)
            (r, g, b, a) = (int >> 24 & 0xff, int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
struct FilledCTA: ButtonStyle {
    var bg: Color = Color("Main")
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 8)
            .background(
                LinearGradient(
                    colors: [bg, bg.opacity(0.9)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: bg.opacity(0.25), radius: 12, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct OutlineCTA: ButtonStyle {
    var tint: Color = Color("Main")
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 8)
            .background(.white)
            .foregroundColor(tint)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint, lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
