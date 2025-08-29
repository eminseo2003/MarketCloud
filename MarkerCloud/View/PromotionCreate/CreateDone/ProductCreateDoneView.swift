//
//  CreateDoneView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import AVKit

struct ProductCreateDoneView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = ProductFeedUpLoadVM()
    
    let mediaUrl: String
    
    @State private var showDeleteAlert = false
    @State private var showPostAlert = false
    @State private var contentText: String
    let method: MediaType
    let feedType: String
    let mediaType: String
    let productName: String
    let categoryId: Int
    let productDescription: String
    let productImage: UIImage
    let currentUserID: Int
    init(mediaUrl: String, body: String, method: MediaType, feedType: String, mediaType: String, productName: String, categoryId: Int, productDescription: String, productImage: UIImage, currentUserID: Int) {
        self.mediaUrl = mediaUrl
        self.method = method
        self.feedType = feedType
        self.mediaType = mediaType
        self.productName = productName
        self.categoryId = categoryId
        self.productDescription = productDescription
        self.productImage = productImage
        self.currentUserID = currentUserID
        _contentText = State(initialValue: body)
    }
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if method == .image {
                    if let url = URL(string: mediaUrl) {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFit()
                        } placeholder: { ProgressView() }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Text("잘못된 이미지 URL")
                    }
                } else {
                    if let url = URL(string: mediaUrl) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(minHeight: 220)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Text("잘못된 비디오 URL")
                    }
                }
                
                TextField("내용을 입력하세요", text: $contentText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("다시 생성하기")
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Main"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("Main"), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        Task {
                            
                            await vm.uploadProductFeed(
                                feedType: feedType,
                                mediaType: mediaType,
                                userId: currentUserID,
                                productName: productName,
                                categoryId: categoryId,
                                productDescription: productDescription,
                                productImage: productImage,
                                feedMediaUrl: mediaUrl,
                                feedBody: contentText
                            )
                            showPostAlert = true
                        }
                    }) {
                        Text("게시하기")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Main"))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("생성 완료")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isTextFieldFocused = false
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").foregroundColor(.primary)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showDeleteAlert = true } label: {
                        Label("삭제", systemImage: "trash").labelStyle(.iconOnly)
                    }
                }
            }

            .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    dismiss()
                }
                Button("취소", role: .cancel) {}
            }
            .alert("게시 완료 되었습니다.", isPresented: $showPostAlert) {
                Button("확인", role: .cancel) {
                    dismiss()
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


