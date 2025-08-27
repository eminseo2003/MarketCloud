//
//  CreateDoneView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import AVKit

struct EventCreateDoneView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = EventFeedUpLoadVM()
    
    let mediaUrl: String
    
    @State private var showDeleteAlert = false
    @State private var showPostAlert = false
    @State private var contentText: String
    let method: MediaType
    let feedType: String
    let mediaType: String
    let storeId: Int
    let eventName: String
    let eventDescription: String
    let eventStartAt: Date
    let eventEndAt: Date
    let eventImage: UIImage
    init(mediaUrl: String, body: String, method: MediaType, feedType: String, mediaType: String, storeId: Int, eventName: String, eventDescription: String, eventStartAt: Date, eventEndAt: Date, eventImage: UIImage) {
        self.mediaUrl = mediaUrl
        self.method = method
        self.feedType = feedType
        self.mediaType = mediaType
        self.storeId = storeId
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventStartAt = eventStartAt
        self.eventEndAt = eventEndAt
        self.eventImage = eventImage
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
                            await vm.uploadEventFeed(
                                feedType: feedType,
                                mediaType: mediaType,
                                storeId: storeId,
                                eventName: eventName,
                                eventDescription: eventDescription,
                                eventStartAt: eventStartAt,
                                eventEndAt: eventEndAt,
                                eventImage: eventImage,
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


