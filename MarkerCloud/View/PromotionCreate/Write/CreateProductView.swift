//
//  CreateProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import PhotosUI

struct CreateProductView: View {
    let feedType: FeedType
    let method: MediaType
    @Binding var currentUserID: Int
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = ProductFeedGenerateVM()
    @State private var createRoute: CreateRoute? = nil
    
    @State private var storeIdText: String = "1"
    @State private var productName: String = ""
    @State private var selectedCategory: String = "음식점"
    private var selectedCategoryId: Int? {
        StoreCategory(label: selectedCategory)?.rawValue
    }
    private let categories: [String] =
        StoreCategory.allCases
            .sorted { $0.rawValue < $1.rawValue }
            .map { $0.displayName }

    @State private var productScript: String = ""
    let maxCharacters = 500
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil
    
    private var hasName: Bool { !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasCategory: Bool { selectedCategory != "전체" }
    private var hasDesc: Bool { !productScript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasImage: Bool { selectedImage != nil }
    
    private var canCreate: Bool {
        hasName && hasCategory && hasDesc && hasImage
    }
    
    @FocusState private var isProductWriteFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("상품명")) {
                    TextField("상품명", text: $productName)
                        .focused($isProductWriteFocused)
                }
                
                Section(header: Text("카테고리")) {
                    FlowLayout(spacing: 8, lineSpacing: 10) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                TagChip(title: cat, isSelected: cat == selectedCategory)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                Section(header: Text("상품 설명")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $productScript)
                            .frame(height: 150)
                            .focused($isProductWriteFocused)
                            .onChange(of: productScript) { oldValue, newValue in
                                if newValue.count > maxCharacters {
                                    productScript = String(newValue.prefix(maxCharacters))
                                }
                            }
                        .frame(height: 150)
                        
                        if productScript.isEmpty {
                            Text("상품 설명")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 6)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("\(productScript.count)/\(maxCharacters)자")
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
            .navigationTitle("상품 홍보 생성하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isProductWriteFocused = false
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
                        guard let categoryId = selectedCategoryId else {
                                vm.errorMessage = "카테고리를 선택해주세요"; return
                            }
                        Task {
                            await vm.uploadProductFeed(
                                feedType: "product",
                                mediaType: method == .image ? "image" : "video",
                                userId: currentUserID,
                                productName: productName,
                                categoryId: categoryId,
                                productDescription: productScript,
                                image: img
                            )
                            if let g = vm.generated {
                                createRoute = .createProductComplete(g)
                                        } else if let err = vm.errorMessage {
                                            print("Upload failed: \(err)")
                                        }
                        }
                        isProductWriteFocused = false
                    }
                    .disabled(!canCreate)
                    .tint(canCreate ? Color("Main") : Color.gray)
                }
            }
            .navigationDestination(item: $createRoute) { route in
                Group {
                    if case let .createProductComplete(dto) = route {
                        if let img = selectedImage, let categoryId = selectedCategoryId {
                            ProductCreateDoneView(
                                mediaUrl: dto.feedMediaUrl,
                                body: dto.feedBody,
                                method: method,
                                feedType: "product",
                                mediaType: (method == .image ? "image" : "video"),
                                productName: productName,
                                categoryId: categoryId,
                                productDescription: productScript,
                                productImage: img,
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
struct TagChip: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isSelected ? .bold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(isSelected ? Color(.systemGray3) : Color(.systemGray5)))
            .foregroundColor(.black)
    }
}
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxWidth {
                x = 0
                y += rowH + lineSpacing
                rowH = 0
            }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxWidth, height: y + rowH)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxWidth {
                x = 0
                y += rowH + lineSpacing
                rowH = 0
            }
            v.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                proposal: ProposedViewSize(width: s.width, height: s.height)
            )
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
