////
////  ReviewWriteView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/14/25.
////
//
//import SwiftUI
//import PhotosUI
//
//struct ReviewWriteView: View {
//    let feed: Feed
//    
//    @Environment(\.dismiss) var dismiss
//    
//    @State private var content: String = ""
//    let maxCharacters = 500
//    @State private var selectedImage: UIImage? = nil
//    @State private var rating: Int = 0
//    
//    private var canPost: Bool {
//        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
//        return !trimmed.isEmpty && rating > 0
//    }
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("리뷰 내용")) {
//                    ZStack(alignment: .topLeading) {
//                        TextEditor(text: Binding(
//                            get: { content },
//                            set: { newValue in
//                                if newValue.count <= maxCharacters {
//                                    content = newValue
//                                } else {
//                                    content = String(newValue.prefix(maxCharacters))
//                                }
//                            }
//                        ))
//                        .frame(height: 150)
//                        
//                        if content.isEmpty {
//                            Text("해당 상품에 대한 리뷰를 작성해주세요")
//                                .foregroundColor(.gray)
//                                .padding(.top, 8)
//                                .padding(.leading, 6)
//                        }
//                    }
//                    HStack {
//                        Spacer()
//                        Text("\(content.count)/\(maxCharacters)자")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//                
//                Section(header: Text("이미지")) {
//                    PhotosPicker(
//                        selection: Binding(
//                            get: { nil },
//                            set: { item in
//                                if let item = item {
//                                    Task {
//                                        if let data = try? await item.loadTransferable(type: Data.self),
//                                           let uiImage = UIImage(data: data) {
//                                            selectedImage = uiImage
//                                        }
//                                    }
//                                }
//                            }
//                        ),
//                        matching: .images
//                    ) {
//                        HStack {
//                            Image(systemName: "photo.on.rectangle")
//                            Text(selectedImage == nil ? "이미지 추가" : "다른 이미지로 변경")
//                        }
//                        .foregroundColor(.blue)
//                    }
//                    if let image = selectedImage {
//                        ZStack(alignment: .topTrailing) {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 100, height: 100)
//                                .clipped()
//                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                        .stroke(Color(.systemGray5), lineWidth: 1)
//                                )
//                            
//                            Button {
//                                withAnimation {
//                                    selectedImage = nil
//                                }
//                            } label: {
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.title2)
//                                    .symbolRenderingMode(.palette)
//                                    .foregroundStyle(.white, Color.black.opacity(0.6))
//                                    .padding(8)
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    
//                    
//                }
//                
//                
//                Section(header: Text("평점")) {
//                    HStack {
//                        Spacer()
//                        ForEach(1...5, id: \.self) { index in
//                            Image(systemName: index <= rating ? "star.fill" : "star")
//                                .resizable()
//                                .frame(width: 28, height: 28)
//                                .foregroundColor(Color("Main"))
//                                .onTapGesture {
//                                    rating = index
//                                }
//                        }
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.vertical, 8)
//                }
//            }
//            .navigationTitle("리뷰 작성하기")
//            .navigationBarTitleDisplayMode(.inline)
//            
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("취소") {
//                        dismiss()
//                    }
//                    .tint(Color("Main"))
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("게시") {
//                        // 게시 처리
//                        dismiss()
//                    }
//                    .tint(canPost ? Color("Main") : Color.gray)
//                    .disabled(!canPost)
//                }
//            }
//        }
//    }
//}
