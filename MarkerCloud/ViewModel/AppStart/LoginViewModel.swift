//
//  LoginViewModel.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/28/25.
//

import Foundation
import Combine
import Alamofire

struct LoginRequest: Encodable {
    let id: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let id: String
    let uno: Int?
}

enum FlexibleError: Decodable {
    case string(String)
    case int(Int)

    var text: String {
        switch self {
        case .string(let s): return s
        case .int(let i):    return String(i)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) {
            self = .int(i)
        } else if let s = try? c.decode(String.self) {
            self = .string(s)
        } else if c.decodeNil() {
            self = .string("")
        } else {
            throw DecodingError.typeMismatch(String.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported error type"))
        }
    }
}

struct LoginResponse: Decodable {
    let responseDto: LoginResponseDTO?
    let error: FlexibleError?
    let success: Bool?
}


@MainActor
final class LoginViewModel: ObservableObject {

    @Published var userId: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var canSubmit: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published var loggedInUser: LoginResponseDTO?

    private var bag = Set<AnyCancellable>()

    private let base = URL(string: "https://famous-blowfish-plainly.ngrok-free.app")!

    init() {
        Publishers.CombineLatest($userId, $password)
            .map { id, pw in
                !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                pw.count >= 8
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &bag)
    }

    private func makeURL() -> URL {
        base
            .appendingPathComponent("api")
            .appendingPathComponent("user")
            .appendingPathComponent("login")
            .appendingPathComponent("")
    }

    func login() {
        errorMessage = nil
        successMessage = nil
        loggedInUser = nil

        guard canSubmit else {
            errorMessage = "아이디/비밀번호를 확인해 주세요."
            return
        }

        let payload = LoginRequest(
            id: userId.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        let url = makeURL()
        isLoading = true

        do {
            var req = URLRequest(url: url)
            req.method = .post
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            req.httpBody = try encoder.encode(payload)

            print("\n----- LOGIN REQUEST -----")
            print("URL: \(req.url?.absoluteString ?? "nil")")
            print("Method: \(req.method?.rawValue ?? "nil")")
            print("Headers: \(req.allHTTPHeaderFields ?? [:])")
            if let body = req.httpBody, let json = String(data: body, encoding: .utf8) {
                print("Body(JSON):\n\(json)")
            }
            print("-------------------------\n")

            AF.request(req)
                .validate(statusCode: 200..<300)
                .publishDecodable(type: LoginResponse.self)
                .value()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    if case let .failure(error) = completion {
                        self.errorMessage = Self.humanize(error: error.asAFError ?? AFError.explicitlyCancelled)
                    }
                } receiveValue: { [weak self] (resp: LoginResponse) in
                    guard let self = self else { return }
                    if resp.success == true, let dto = resp.responseDto {
                        self.loggedInUser = dto
                        self.successMessage = "로그인 되었습니다."
                    } else {
                        let msg = resp.error?.text
                        self.errorMessage = (msg?.isEmpty == false) ? msg : "로그인에 실패했습니다."
                    }
                }
                .store(in: &bag)

        } catch {
            isLoading = false
            errorMessage = "요청 바디 인코딩 실패: \(error.localizedDescription)"
        }
    }

    func reset() {
        userId = ""
        password = ""
        errorMessage = nil
        successMessage = nil
        loggedInUser = nil
    }

    private static func humanize(error: AFError) -> String {
        if let underlying = error.underlyingError as NSError? {
            if underlying.domain == NSURLErrorDomain {
                return "네트워크 연결을 확인해 주세요. (\(underlying.code))"
            }
        }
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return "요청이 실패했습니다. (HTTP \(code))"
            }
        default: break
        }
        return "요청 처리 중 오류가 발생했습니다."
    }
}
