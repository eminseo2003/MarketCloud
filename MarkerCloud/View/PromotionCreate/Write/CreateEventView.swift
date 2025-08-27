//
//  CreateEventView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/14/25.
//

import SwiftUI
import PhotosUI

struct CreateEventView: View {
    let feedType: FeedType
    let method: MediaType
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = EventFeedGenerateVM()
    @State private var createRoute: CreateRoute? = nil
    
    @State private var storeIdText: String = "1"
    @State private var eventName: String = ""
    @State private var eventScript: String = ""
    @State var eventStart: Date = Date()
    @State var eventEnd: Date = Date()
    let maxCharacters = 500
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = nil
    
    @FocusState private var isEventScriptFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("이벤트명")) {
                    TextField("이벤트명", text: $eventName)
                        .focused($isEventScriptFocused)
                }
                Section(header: Text("이벤트 진행 일정")) {
                    HStack {
                        Text("시작 시간")
                        Spacer()
                        DatePicker("", selection: $eventStart, displayedComponents: [.date])
                            .labelsHidden()
                        DatePicker("", selection: $eventStart, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                    }
                    HStack {
                        Text("종료 시작")
                        Spacer()
                        DatePicker("", selection: $eventEnd, displayedComponents: [.date])
                            .labelsHidden()
                        DatePicker("", selection: $eventEnd, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                    }
                }
                Section(header: Text("이벤트 설명")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: Binding(
                            get: { eventScript },
                            set: { newValue in
                                if newValue.count <= maxCharacters {
                                    eventScript = newValue
                                } else {
                                    eventScript = String(newValue.prefix(maxCharacters))
                                }
                            }
                        ))
                        .frame(height: 150)
                        .focused($isEventScriptFocused)
                        
                        if eventScript.isEmpty {
                            Text("홍보 게시글을 생성하는 데 사용됩니다.")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 6)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("\(eventScript.count)/\(maxCharacters)자")
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
            .navigationTitle("이벤트 홍보 생성하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isEventScriptFocused = false
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("생성") {
                        guard let img = selectedImage,
                              let storeId = Int(storeIdText) else { return }
                        Task {
                            await vm.uploadEventFeed(
                                feedType: "event",
                                mediaType: method == .image ? "image" : "video",
                                storeId: storeId,
                                eventName: eventName,
                                eventDescription: eventScript,
                                eventStartAt: eventStart,
                                eventEndAt: eventEnd,
                                image: img
                            )
                            if let g = vm.generated {
                                createRoute = .createEventComplete(g)
                                        } else if let err = vm.errorMessage {
                                            print("Upload failed: \(err)")
                                        }
                        }
                        isEventScriptFocused = false
                    }
                }
            }
            .navigationDestination(item: $createRoute) { route in
                Group {
                    if case let .createEventComplete(dto) = route {
                        EventCreateDoneView(mediaUrl: dto.feedMediaUrl, body: dto.feedBody, method: method)

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
