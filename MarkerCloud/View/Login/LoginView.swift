//
//  LoginView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import SwiftUI

struct LoginView: View {
    @FocusState private var focus: Field?
    @State private var email: String = ""
    @State private var password: String = ""
    enum Field { case email, password }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Market Cloud")
                    .font(.largeTitle.bold())
                
                Text("이메일과 비밀번호로 로그인하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.horizontal, 20)

            // 입력 카드
            VStack(spacing: 14) {
                // 이메일
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.secondary)
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .focused($focus, equals: .email)
                        .onSubmit { focus = .password }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

                // 비밀번호 (보기 토글)
                PasswordField(text: $password)
                    .focused($focus, equals: .password)
                    .onSubmit {  }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .padding(.horizontal, 16)
            .padding(.top, 18)


            Spacer(minLength: 16)

            // 로그인 버튼
            VStack(spacing: 12) {
                Button {
                    
                } label: {
                    HStack {
                        Text("로그인")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(FilledCTA())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") { hideKeyboard() }
            }
        }
        .onAppear { focus = .email }
    }
    private func hideKeyboard() {
            focus = nil
        }
}

private struct PasswordField: View {
    @Binding var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)

            Group {
                if isSecure {
                    SecureField("비밀번호 (8자 이상)", text: $text)
                } else {
                    TextField("비밀번호 (8자 이상)", text: $text)
                }
            }
            .textContentType(.password)
            .submitLabel(.go)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSecure ? "비밀번호 보기" : "비밀번호 숨기기")
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

private extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}

