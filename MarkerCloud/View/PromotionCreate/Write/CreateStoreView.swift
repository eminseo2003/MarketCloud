//
//  WriteCreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import PhotosUI

enum CreateRoute: Identifiable, Hashable {
    case createStoreComplete(GenerateDTO)
    case createProductComplete(GenerateDTO)
    case createEventComplete(GenerateDTO)

    var id: String {
        switch self {
        case .createStoreComplete(let dto): return "createComplete:\(dto.id)"
        case .createProductComplete(let dto): return "createComplete:\(dto.id)"
        case .createEventComplete(let dto): return "createComplete:\(dto.id)"
        }
    }
}
struct CreateStoreView: View {
    let feedType: FeedType
    let method: MediaType
    @Binding var currentUserID: Int
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = StoreFeedGenerateVM()
    @State private var createRoute: CreateRoute? = nil
    
    @State private var storeIdText: String = "1"
    @State private var storeName: String = "점포 명"
    @State private var storeScript: String = ""
    let maxCharacters = 500
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil
    
    private var canCreate: Bool {
        selectedImage != nil
    }
    
    @FocusState private var isStoreScriptFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("점포명")) {
                    HStack {
                        Text(storeName)
                            .font(.body)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
                
                Section(header: Text("점포 설명")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $storeScript)
                            .frame(height: 150)
                            .focused($isStoreScriptFocused)
                            .onChange(of: storeScript) { oldValue, newValue in
                                if newValue.count > maxCharacters {
                                    storeScript = String(newValue.prefix(maxCharacters))
                                }
                            }
                        .frame(height: 150)
                        if storeScript.isEmpty {
                            Text("점포 설명")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 6)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("\(storeScript.count)/\(maxCharacters)자")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Section(header: Text("이미지")) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedImage == nil ? "이미지 추가" : "다른 이미지로 변경")
                        }
                    }
                    if let image = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable().scaledToFill()
                                .frame(width: 100, height: 100).clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(.systemGray5), lineWidth: 1))
                            
                            Button {
                                withAnimation { selectedImage = nil }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, Color.black.opacity(0.6))
                                    .padding(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("점포 홍보 생성하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isStoreScriptFocused = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        guard let img = selectedImage else { return }
                        Task {
                            await vm.uploadStoreFeed(
                                feedType: "store",
                                mediaType: method == .image ? "image" : "video",
                                userId: currentUserID,
                                storeDescription: storeScript,
                                image: img
                            )
                            if let g = vm.generated {
                                createRoute = .createStoreComplete(g)
                                        } else if let err = vm.errorMessage {
                                            print("❌ Upload failed: \(err)")
                                        }
                        }
                        isStoreScriptFocused = false
                    }
                    .disabled(!canCreate)
                    .tint(canCreate ? Color("Main") : Color.gray)
                }
            }
            .navigationDestination(item: $createRoute) { route in
                Group {
                    if case let .createStoreComplete(dto) = route {
                        if let img = selectedImage {
                            StoreCreateDoneView(
                                mediaUrl: dto.feedMediaUrl,
                                body: dto.feedBody,
                                method: method,
                                feedType: "store",
                                mediaType: (method == .image ? "image" : "video"),
                                storeDescription: storeScript,
                                storeImage: img,
                                currentUserID: currentUserID
                            )
                        } else {
                            Text("필수 값이 없습니다. (이미지/점포 ID)")
                        }

                    } else {
                        EmptyView()
                    }
                }
            }


            .onChange(of: photoItem) { _, item in
                guard let item else { selectedImage = nil; return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
            .overlay {
                if vm.isUploading {
                    ZStack {
                        Color.black.opacity(0.25).ignoresSafeArea()
                        ProgressView("업로드 중…")
                            .padding().background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .alert("오류", isPresented: .constant(vm.errorMessage != nil)) {
                Button("확인") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}
