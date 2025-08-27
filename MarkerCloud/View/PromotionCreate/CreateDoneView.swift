//
//  CreateDoneView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import AVKit

struct CreateDoneView: View {
    @Environment(\.dismiss) var dismiss
    
    let mediaUrl: String
    
    @State private var showDeleteAlert = false
    @State private var showPostAlert = false
    @State private var contentText: String
    init(mediaUrl: String, body: String) {
            self.mediaUrl = mediaUrl
            _contentText = State(initialValue: body)
        }
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                AsyncImage(url: URL(string: mediaUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                } placeholder: {
                    ProgressView()
                }
//                if post.mediaType == .image {
//                    AsyncImage(url: mediaUrl) { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color(.systemGray6))
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    } placeholder: {
//                        ProgressView()
//                    }
//                } else if post.mediaType == .video {
//                    VideoPlayer(player: AVPlayer(url: post.mediaUrl))
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
                
                TextField("내용을 입력하세요", text: $contentText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("완료") {
                                isTextFieldFocused = false
                            }
                        }
                    }
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
                        showPostAlert = true
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss() // 현재 뷰 닫기
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Label("삭제", systemImage: "trash")
                            .labelStyle(.iconOnly)
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
        }
    }
}


