////
////  WriteCreateView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/14/25.
////
//
//import SwiftUI
//import PhotosUI
//
//struct CreateStoreView: View {
//    let method: Method
//    let promotion: Promotion
//    
//    @Environment(\.dismiss) var dismiss
//    @State private var route: Route? = nil
//    
//    @State private var storeName: String = "내 점포 이름"
//    @State private var storeScript: String = ""
//    let maxCharacters = 500
//    @State private var selectedImage: UIImage? = nil
//
//    private var canCreate: Bool {
//            selectedImage != nil
//        }
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("점포명")) {
//                    HStack {
//                        Text(storeName)
//                            .font(.body)
//                            .lineLimit(1)
//
//                        Spacer()
//                    }
//                }
//
//                Section(header: Text("점포 설명")) {
//                    ZStack(alignment: .topLeading) {
//                        TextEditor(text: Binding(
//                            get: { storeScript },
//                            set: { newValue in
//                                if newValue.count <= maxCharacters {
//                                    storeScript = newValue
//                                } else {
//                                    storeScript = String(newValue.prefix(maxCharacters))
//                                }
//                            }
//                        ))
//                        .frame(height: 150)
//                        
//                        if storeScript.isEmpty {
//                            Text("점포 설명")
//                                .foregroundColor(.gray)
//                                .padding(.top, 8)
//                                .padding(.leading, 6)
//                        }
//                    }
//                    HStack {
//                        Spacer()
//                        Text("\(storeScript.count)/\(maxCharacters)자")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
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
//            }
//            .navigationTitle("점포 홍보 생성하기")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("취소") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("생성") {
//                        route = .createComplete
//                    }
//                    .disabled(!canCreate)
//                    .tint(canCreate ? Color("Main") : Color.gray)
//                }
//            }
//            .navigationDestination(item: $route) { route in
//                if route == .createComplete {
//                    CreateDoneView(post: dummyFeed[0])
//                    }
//            }
//        }
//        
//        
//        
//    }
//}
