//
//  JoinView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/26/25.
//

import SwiftUI

struct JoinView: View {
    @State private var showSuccessAlert = false
    @FocusState private var focus: Field?
    enum Field { case name, email, password, isHost }
    
    @StateObject private var vm = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showErrorAlert = false
    @State private var showValidationAlert = false
    @State private var validationAlertMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Market Cloud")
                    .font(.largeTitle.bold())
                
                Text("Market Cloud에 오신걸 환영합니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.horizontal, 20)
            
            // 입력 카드
            ScrollView {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                        TextField("이름", text: $vm.username)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                            .focused($focus, equals: .name)
                            .onSubmit { focus = .email }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    // 이메일
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                        TextField("이메일", text: $vm.userId)
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
                    PasswordField(text: $vm.password)
                        .focused($focus, equals: .password)
                        .onSubmit {  }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $vm.isHost) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("상인 계정으로 가입")
                                    .font(.subheadline)
                                Text("점포 관리, 상품 등록 기능이 활성화됩니다.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(Color("Main"))
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            
            
            
            Spacer(minLength: 16)
            
            VStack(spacing: 12) {
                Button {
                    let nameT = vm.username.trimmingCharacters(in: .whitespacesAndNewlines)
                        if nameT.isEmpty {
                            validationAlertMessage = "이름을 입력해 주세요."
                            showValidationAlert = true
                            hideKeyboard()
                            return
                        }
                        if !vm.userId.isValidEmail {
                            validationAlertMessage = "올바른 이메일 형식이 아닙니다."
                            showValidationAlert = true
                            hideKeyboard()
                            return
                        }
                        if vm.password.count < 8 {
                            validationAlertMessage = "비밀번호는 8자 이상 입력해 주세요."
                            showValidationAlert = true
                            hideKeyboard()
                            return
                        }
                    vm.register()
                } label: {
                    HStack {
                        Text("회원가입")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(FilledCTA())
                .disabled(vm.isLoading)
                //.disabled(!vm.canSubmit || vm.isLoading)
                //if let vmsg = vm.validationMessage { Text(vmsg).foregroundColor(.red) }
                //if let err  = vm.errorMessage      { Text(err).foregroundColor(.red) }

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
        .onAppear { focus = .name }
        .onChange(of: vm.successMessage) { newValue in
            if newValue != nil {
                showSuccessAlert = true
                hideKeyboard()
            }
        }
        .onChange(of: vm.errorMessage) { newValue in
            if newValue != nil {
                showErrorAlert = true
                hideKeyboard()
            }
        }
        .alert("입력값을 확인해 주세요", isPresented: $showValidationAlert, actions: {
            Button("확인", role: .cancel) { }
        }, message: {
            Text(vm.validationMessage ?? "필수 입력값을 확인해 주세요.")
        })

        .alert("회원가입 완료", isPresented: $showSuccessAlert, actions: {
            Button("확인") {
                dismiss()
            }
        }, message: {
            Text(vm.successMessage ?? "회원가입이 정상적으로 처리되었습니다.")
        })
        .alert("회원가입 실패", isPresented: $showErrorAlert, actions: {
            Button("확인", role: .cancel) { }
        }, message: {
            Text(vm.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        })

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

