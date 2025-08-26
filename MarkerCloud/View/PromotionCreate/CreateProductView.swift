//
//  CreateProductView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import PhotosUI

struct CreateProductView: View {
    let method: Method
    let promotion: Promotion
    
    @Environment(\.dismiss) var dismiss
    @State private var route: Route? = nil
    
    @State private var productName: String = ""
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = [
        "전체","음식점","반찬","카페·제과·간식","옷가게","한복·이불·혼수",
        "패션잡화·화장품","생활·주방·문구","꽃·악기·화구","농자재·철물","사진·뷰티·게임", "수산물", "축산물","과일야채", "기타"
    ]
    private var productCategory: String { selectedCategory == "전체" ? "" : selectedCategory }
    @State private var productScript: String = ""
    let maxCharacters = 500
    @State private var selectedImage: UIImage? = nil
    
    private var hasName: Bool { !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasCategory: Bool { selectedCategory != "전체" }
    private var hasDesc: Bool { !productScript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var hasImage: Bool { selectedImage != nil }
    
    private var canCreate: Bool {
        hasName && hasCategory && hasDesc && hasImage
    }
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("상품명")) {
                    TextField("상품명", text: $productName)
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
                        TextEditor(text: Binding(
                            get: { productScript },
                            set: { newValue in
                                if newValue.count <= maxCharacters {
                                    productScript = newValue
                                } else {
                                    productScript = String(newValue.prefix(maxCharacters))
                                }
                            }
                        ))
                        .frame(height: 150)
                        
                        if productScript.isEmpty {
                            Text("홍보 게시글을 생성하는 데 사용됩니다.")
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
                    PhotosPicker(
                        selection: Binding(
                            get: { nil },
                            set: { item in
                                if let item = item {
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            selectedImage = uiImage
                                        }
                                    }
                                }
                            }
                        ),
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedImage == nil ? "이미지 추가" : "다른 이미지로 변경")
                        }
                        .foregroundColor(.blue)
                    }
                    if let image = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            
                            Button {
                                withAnimation {
                                    selectedImage = nil
                                }
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        route = .createComplete
                    }
                    .disabled(!canCreate)
                    .tint(canCreate ? Color("Main") : Color.gray)
                }
            }
            .navigationDestination(item: $route) { route in
                if route == .createComplete {
                    CreateDoneView(post: dummyFeed[0])
                }
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
