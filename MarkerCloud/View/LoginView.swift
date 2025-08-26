//
//  ContentView.swift
//  MarkerCloud
//
//  Created by 이민서 on 7/30/25.
//

//import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift
//
//struct LoginView: View {
//    @StateObject private var loginViewModel = UnifiedLoginViewModel()
//    
//    var body: some View {
//        VStack {
//            if loginViewModel.isLoggedIn, let user = loginViewModel.user {
//                VStack(spacing: 10) {
//                    Text("환영합니다, \(user.name)님!")
//                        .font(.title)
//                        .bold()
//                    Text("ID: \(user.id)")
//                    Text("이메일: \(user.email ?? "없음")")
//                        .foregroundColor(.gray)
//                }
//            } else {
//                ZStack {
//                    Image("loginBackground")
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
//                    Text("동대문구 전통시장을 한 눈에")
//                        .foregroundColor(Color(hex: "#4A4A4A"))
//                        .font(.title2)
//                        .bold()
//                        .padding(.bottom, 50)
//                    VStack(spacing: 16) {
//                        Spacer()
//                        Button(action: {
//                            loginViewModel.loginWithKakao()
//                        }) {
//                            ZStack{
//                                
//                                Text("카카오로 시작하기")
//                                    .font(.headline)
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.white)
//                                    .foregroundColor(.black)
//                                    .cornerRadius(10)
//                                HStack {
//                                    Image("kakaologo")
//                                        .resizable()
//                                        .frame(width: 24, height: 24)
//                                        .padding()
//                                    Spacer()
//                                }
//                                
//                            }
//                            
//                        }
//                        Button(action: {
//                            signInWithGoogle()
//                        }) {
//                            ZStack {
//                                
//                                Text("구글로 시작하기")
//                                    .font(.headline)
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.white)
//                                    .foregroundColor(.black)
//                                    .cornerRadius(10)
//                                HStack{
//                                    Image("googlelogo")
//                                        .resizable()
//                                        .frame(width: 24, height: 24)
//                                        .padding()
//                                    Spacer()
//                                }
//                                
//                            }
//                            
//                        }
//                    }
//                    .padding(.horizontal, 32)
//                    .padding(.bottom, 100)
//                }
//                
//            }
//        }
//    }
//    
//    // ✅ Google 로그인 로직
//    func signInWithGoogle() {
//        guard let rootViewController = UIApplication.shared.connectedScenes
//            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
//            .first else {
//            print("❌ 루트 뷰 컨트롤러를 찾을 수 없습니다.")
//            return
//        }
//        
//        loginViewModel.loginWithGoogle(presenting: rootViewController)
//    }
//}
//
//extension Color {
//    init(hex: String) {
//        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hex = hex.replacingOccurrences(of: "#", with: "")
//
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//
//        let r, g, b, a: UInt64
//        switch hex.count {
//        case 6: // RGB (예: #AABBCC)
//            (r, g, b, a) = (int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff, 255)
//        case 8: // RGBA (예: #AABBCCDD)
//            (r, g, b, a) = (int >> 24 & 0xff, int >> 16 & 0xff, int >> 8 & 0xff, int & 0xff)
//        default:
//            (r, g, b, a) = (0, 0, 0, 255)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
