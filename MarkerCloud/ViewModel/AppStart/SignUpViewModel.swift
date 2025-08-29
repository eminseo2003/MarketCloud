//
//  SignUpViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import Combine
import Alamofire

struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let name: String
    let isHost: Bool
}

struct SignUpResponse: Decodable {
    let success: Bool?
    let message: String?
}

@MainActor
final class SignUpViewModel: ObservableObject {
    
    @Published var userId: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var isHost: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var canSubmit: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest3($userId, $password, $username)
            .map { id, pw, name in
                return id.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 &&
                pw.count >= 8 &&
                name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &bag)
    }
    
    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!
    
    private func makeURL() -> URL {
        base.appendingPathComponent("api")
            .appendingPathComponent("user")
            .appendingPathComponent("register")
    }
    
    func register() {
        errorMessage = nil
        successMessage = nil
        
        guard canSubmit else {
            errorMessage = "입력값을 확인해 주세요."
            return
        }
        
        let payload = SignUpRequest(
            email: userId.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            name: username.trimmingCharacters(in: .whitespacesAndNewlines),
            isHost: isHost
        )
        
        let url = makeURL()
        
        isLoading = true
        
        do {
            // 1) URLRequest 생성 (보낼 내용 그대로 셋업)
            var req = URLRequest(url: url)
            req.method = .post
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // 보기 좋게
            req.httpBody = try encoder.encode(payload)
            
            // 2) 전송 전에 "정확히 무엇을 보낼지" 출력
            print("\n----- OUTGOING REQUEST -----")
            print("URL: \(req.url?.absoluteString ?? "nil")")
            print("Method: \(req.method?.rawValue ?? "nil")")
            print("Headers:")
            req.allHTTPHeaderFields?.forEach { print("  \($0.key): \($0.value)") }
            if let body = req.httpBody, let json = String(data: body, encoding: .utf8) {
                print("Body(JSON):\n\(json)")
            } else {
                print("Body: nil")
            }
            print("----------------------------\n")
            
            // 3) 만든 URLRequest 그대로 전송
            AF.request(req)
                .validate(statusCode: 200..<300)
                .publishDecodable(type: SignUpResponse.self)
                .value()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    if case let .failure(error) = completion {
                        self.errorMessage = Self.humanize(error: error.asAFError ?? AFError.explicitlyCancelled)
                    }
                } receiveValue: { [weak self] (resp: SignUpResponse) in
                    guard let self = self else { return }
                    if resp.success == true {
                        self.successMessage = resp.message ?? "회원가입이 완료되었습니다."
                    } else {
                        self.errorMessage = resp.message ?? "회원가입에 실패했습니다."
                    }
                }
                .store(in: &bag)
            
        } catch {
            isLoading = false
            errorMessage = "요청 바디 인코딩 실패: \(error.localizedDescription)"
        }
    }
    private static func humanize(error: AFError) -> String {
        if let underlying = error.underlyingError as NSError? {
            if underlying.domain == NSURLErrorDomain {
                return "네트워크 연결을 확인해 주세요. (\(underlying.code))"
            }
        }
        switch error {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                return "요청이 실패했습니다. (HTTP \(code))"
            default: break
            }
        default: break
        }
        return "요청 처리 중 오류가 발생했습니다."
    }
}
