//
//  ChangeProfileView.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/5/25.
//

import SwiftUI
import PhotosUI

@MainActor
struct ChangeProfileView: View {
    let userId: String
    @StateObject private var vm = UserProfileVM()
    @Environment(\.dismiss) private var dismiss

    @State private var photoItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showError = false

    @MainActor var body: some View {
        let localPickedImage = pickedImage
        let profileURLString = vm.profileURL
        ScrollView {
            VStack(spacing: 16) {

                PhotosPicker(selection: $photoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let img = localPickedImage {
                                Image(uiImage: img).resizable().scaledToFill()
                            } else if
                                let s = profileURLString,
                                let url = URL(string: s)
                            {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Circle().fill(Color(uiColor: .systemGray5))
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable().scaledToFit()
                                    .foregroundStyle(.secondary)
                                    .padding(12)
                            }
                        }
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())

                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color("Main"))
                            .background(Circle().fill(.white))
                            .clipShape(Circle())
                            .offset(x: 4, y: 4)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: photoItem) { _, newItem in
                    guard let item = newItem else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImg = UIImage(data: data) {
                            pickedImage = uiImg
                        }
                    }
                }
                .padding(.vertical)

                VStack(spacing: 1) {
                    HStack {
                        Text("이름").font(.body).bold().foregroundColor(.primary)
                        Spacer(minLength: 12)
                        TextField("표시 이름", text: $vm.userName)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .frame(minHeight: 46)
                    .padding(.vertical, 6)

                    Divider()

                    HStack {
                        Text("이메일").font(.body).bold().foregroundColor(.primary)
                        Spacer(minLength: 12)
                        Text(vm.email.isEmpty ? " " : vm.email)
                            .foregroundColor(.secondary)
                    }
                    .frame(minHeight: 46)
                    .padding(.vertical, 6)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .padding(.horizontal, 16)

                if vm.profileURL != nil || pickedImage != nil {
                    Button(role: .destructive) {
                        Task { await vm.removePhoto(userId: userId) }
                        pickedImage = nil
                    } label: {
                        Label("프로필 사진 제거", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await vm.save(userId: userId, pickedImage: pickedImage)
                        dismiss()
                    }
                } label: {
                    Text(vm.isSaving ? "저장중…" : "저장").bold()
                }
                .disabled(vm.isSaving || vm.userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .overlay {
            if vm.isLoading || vm.isSaving {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .task(id: userId) {
            await vm.load(userId: userId)
        }
        .onChange(of: vm.errorMessage) { _, _ in showError = vm.errorMessage != nil }
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
