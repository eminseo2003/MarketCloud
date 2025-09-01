//
//  WriteCreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

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
struct StoreLite: Identifiable, Hashable {
    let id: String
    let name: String
}
struct CreateStoreView: View {
    let feedType: FeedType
    let method: MediaType
    let appUser: AppUser?
    let selectedMarketID: Int
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm = StoreFeedGenerateVM()
    @StateObject private var myStoresVM = MyStoresVM()
    
    @State private var createRoute: CreateRoute? = nil
    
    @State private var selectedStoreId: String?
    @State private var selectedStoreName: String = ""
    
    @State private var storeScript: String = ""
    let maxCharacters = 500
    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil
    
    private var canCreate: Bool {
        guard selectedStoreId != nil else { return false }
        guard !storeScript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        if method == .image {
            return selectedImage != nil
        } else {
            return false
        }
    }
    
    private var ownerId: String? {
        appUser?.id ?? Auth.auth().currentUser?.uid
    }
    
    @FocusState private var isStoreScriptFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("내 점포")) {
                    if myStoresVM.isLoading {
                        ProgressView("불러오는 중…")
                    } else if let err = myStoresVM.errorMessage {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("점포 정보를 불러오지 못했어요.")
                            Text(err).font(.caption).foregroundColor(.secondary)
                            Button("다시 시도") {
                                Task {
                                    if let uid = ownerId { await myStoresVM.load(ownerId: uid, marketId: selectedMarketID) }
                                }
                            }
                        }
                    } else if let s = myStoresVM.store {
                        HStack {
                            Text(s.name).font(.body)
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color("Main"))
                        }
                        .onAppear {
                            selectedStoreId = s.id
                            selectedStoreName = s.name
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("현재 시장에 등록된 내 점포가 없습니다.")
                            Text("먼저 점포를 등록해 주세요.").font(.caption).foregroundColor(.secondary)
                        }
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
                        guard let ownerId, let storeId = selectedStoreId else { return }
                        guard let img = selectedImage else { return }
                        
                        let desc = storeScript.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        Task {
                            await vm.uploadStoreFeed(
                                feedType: feedType,
                                mediaType: method,
                                userId: ownerId,
                                storeId: storeId,
                                marketId: selectedMarketID,
                                title: selectedStoreName,
                                storeDescription: desc,
                                image: img
                            )
                            
                            if let g = vm.generated {
                                createRoute = .createStoreComplete(g)
                            } else if let err = vm.errorMessage {
                                print("Upload failed:", err)
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
                            StoreCreateDoneView(dto: dto, method: method)
                    } else {
                        EmptyView()
                    }
                }
            }
            .task {
                guard let ownerId else { return }
                await myStoresVM.load(ownerId: ownerId, marketId: selectedMarketID)
                if let s = myStoresVM.store {
                    selectedStoreId = s.id
                    selectedStoreName = s.name
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
