//
//  CreateDoneView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import AVKit
import FirebaseFirestore
import FirebaseStorage

struct StoreCreateDoneView: View {
    @Environment(\.dismiss) var dismiss
    
    let dto: GenerateDTO
    let method: MediaType
    
    @State private var showDeleteAlert = false
    @State private var showPostAlert = false
    @State private var contentText: String
    
    @State private var isPublishing = false
        @State private var publishError: String?
    @FocusState private var isTextFieldFocused: Bool
    
    init(dto: GenerateDTO, method: MediaType) {
        self.dto = dto
        self.method = method
        _contentText = State(initialValue: dto.feedBody)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if method == .image {
                    if let url = URL(string: dto.feedMediaUrl) {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        Text("잘못된 이미지 URL")
                    }
                } else {
                    if let url = URL(string: dto.feedMediaUrl) {
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
                            do {
                                try await Firestore.firestore()
                                    .collection("feeds").document(dto.id)
                                    .setData([
                                        "body": contentText,
                                        "isPublished": true,
                                        "updatedAt": FieldValue.serverTimestamp()
                                    ], merge: true)
                                showPostAlert = true
                            } catch {
                                print("publish error:", error.localizedDescription)
                            }
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isTextFieldFocused = false
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
                            if isPublishing {
                                ZStack {
                                    Color.black.opacity(0.25).ignoresSafeArea()
                                    ProgressView("업로드 중…")
                                        .padding().background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .alert("오류", isPresented: .constant(publishError != nil)) {
                            Button("확인") { publishError = nil }
                        } message: {
                            Text(publishError ?? "")
                        }
        }
    }
}


