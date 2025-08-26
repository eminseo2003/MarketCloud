////
////  DetailInfoView.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/14/25.
////
//
//import SwiftUI
//import PhotosUI
//
//struct DetailInfoView: View {
//    @Environment(\.dismiss) var dismiss
//    
//    @ObservedObject var storeDetail: StoreDetail
//    private let categories: [String] = [
//        "전체","음식점","반찬","카페·제과·간식","옷가게","한복·이불·혼수",
//        "패션잡화·화장품","생활·주방·문구","꽃·악기·화구","농자재·철물","사진·뷰티·게임", "수산물", "축산물","과일야채", "기타"
//    ]
//    @State var selectedStoreImage: [UIImage] = []
//    let maxCharacters = 500
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("업종 구분")) {
//                    FlowLayout(spacing: 8, lineSpacing: 10) {
//                        ForEach(categories, id: \.self) { cat in
//                            Button {
//                                selectedCategory = cat
//                            } label: {
//                                TagChip(title: cat, isSelected: cat == selectedCategory)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.top, 4)
//                }
//                Section(header: Text("전화번호")) {
//                    TextField("전화번호를 입력해주세요", text: $storeDetail.phoneNumber)
//                        .keyboardType(.phonePad)
//                }
//                
//                Section(header: Text("운영시간")) {
//                    HStack {
//                        Text("평일 운영 시간")
//                        Spacer()
//                        DatePicker("", selection: $storeDetail.weekdayOpen, displayedComponents: [.hourAndMinute])
//                            .labelsHidden()
//                        Text("~")
//                        DatePicker("", selection: $storeDetail.weekdayClose, displayedComponents: [.hourAndMinute])
//                            .labelsHidden()
//                    }
//                    HStack {
//                        Text("주말 운영 시간")
//                        Spacer()
//                        DatePicker("", selection: $storeDetail.weekendOpen, displayedComponents: [.hourAndMinute])
//                            .labelsHidden()
//                        Text("~")
//                        DatePicker("", selection: $storeDetail.weekendClose, displayedComponents: [.hourAndMinute])
//                            .labelsHidden()
//                    }
//                }
//                
//                Section(header: Text("주소")) {
//                    TextField("도로명 주소를 입력해주세요", text: $storeDetail.roadAddress)
//                    TextField("지번 주소를 입력해주세요", text: $storeDetail.jibunAddress)
//                }
//                
//                Section(header: Text("결제가능수단")) {
//                    Toggle("온누리상품권", isOn: Binding(
//                        get: { storeDetail.usesVouchers.contains("온누리상품권") },
//                        set: { newValue in
//                            if newValue {
//                                storeDetail.usesVouchers.append("온누리상품권")
//                            } else {
//                                storeDetail.usesVouchers.removeAll { $0 == "온누리상품권" }
//                            }
//                        }
//                    ))
//                    
//                    Toggle("제로페이", isOn: Binding(
//                        get: { storeDetail.usesVouchers.contains("제로페이") },
//                        set: { newValue in
//                            if newValue {
//                                storeDetail.usesVouchers.append("제로페이")
//                            } else {
//                                storeDetail.usesVouchers.removeAll { $0 == "제로페이" }
//                            }
//                        }
//                    ))
//                    
//                    Toggle("민생회복쿠폰", isOn: Binding(
//                        get: { storeDetail.usesVouchers.contains("민생회복쿠폰") },
//                        set: { newValue in
//                            if newValue {
//                                storeDetail.usesVouchers.append("민생회복쿠폰")
//                            } else {
//                                storeDetail.usesVouchers.removeAll { $0 == "민생회복쿠폰" }
//                            }
//                        }
//                    ))
//                }
//                Section(header: Text("점포 소개")) {
//                    ZStack(alignment: .topLeading) {
//                        TextEditor(text: Binding(
//                            get: { storeDetail.storeDescription },
//                            set: { newValue in
//                                if newValue.count <= maxCharacters {
//                                    storeDetail.storeDescription = newValue
//                                } else {
//                                    storeDetail.storeDescription = String(newValue.prefix(maxCharacters))
//                                }
//                            }
//                        ))
//                        .frame(height: 150)
//                        
//                        if storeDetail.storeDescription.isEmpty {
//                            Text("점포 소개")
//                                .foregroundColor(.gray)
//                                .padding(.top, 8)
//                                .padding(.leading, 6)
//                        }
//                    }
//                    HStack {
//                        Spacer()
//                        Text("\(storeDetail.storeDescription.count)/\(maxCharacters)자")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .navigationTitle("세부사항")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("추가") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
