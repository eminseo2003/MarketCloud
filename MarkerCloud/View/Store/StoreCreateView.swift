//
//  FirstStoreCreateView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct StoreCreateView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var storeDetail: StoreDetail
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    
    @StateObject private var createVm = StoreCreateVM()
    @StateObject private var hasStoreVm = StoreMembershipVM()
    //    @StateObject private var lookUpVm = StoreLookupVM()
    @State private var showLookupAlert = false
    @State private var lookupAlertMessage = ""
    
    //점포 이미지
    @State var selectedStoreImage: [UIImage] = []
    
    //글자수 제한
    let maxCharacters = 500
    @FocusState private var isTextFieldFocused: Bool
    
    //점포 명
    @State private var storeName: String = ""
    
    //점포 카테고리
    private let storePromotion = Promotion(name: "점포", imageName: "loginBackground")
    @State private var selectedCategory: String = "음식점"
    private var selectedCategoryId: Int? {
        StoreCategory(label: selectedCategory)?.rawValue
    }
    private let categories: [String] =
    StoreCategory.allCases
        .sorted { $0.rawValue < $1.rawValue }
        .map { $0.displayName }
    
    //피드 생성 route
    @State private var pushPromotion: Promotion? = nil
    var body: some View {
        Form {
            Section(header: Text("점포명")) {
                TextField("점포명", text: $storeName)
                    .padding(.trailing, 36)
                    .focused($isTextFieldFocused)
            }
            
            Section(header: Text("업종 구분")) {
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
            Section(header: Text("전화번호")) {
                TextField("전화번호를 입력해주세요", text: $storeDetail.phoneNumber)
                    .keyboardType(.phonePad)
                    .focused($isTextFieldFocused)
            }
            
            Section(header: Text("운영시간")) {
                HStack {
                    Text("평일 운영 시간")
                    Spacer()
                    DatePicker("", selection: $storeDetail.weekdayOpen, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                    Text("~")
                    DatePicker("", selection: $storeDetail.weekdayClose, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                HStack {
                    Text("주말 운영 시간")
                    Spacer()
                    DatePicker("", selection: $storeDetail.weekendOpen, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                    Text("~")
                    DatePicker("", selection: $storeDetail.weekendClose, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
            }
            
            Section(header: Text("주소")) {
                TextField("주소를 입력해주세요", text: $storeDetail.roadAddress)
                    .focused($isTextFieldFocused)
            }
            
            Section(header: Text("결제가능수단")) {
                Toggle("온누리 상품권", isOn: Binding(
                    get: { storeDetail.usesVouchers.contains("온누리 상품권") },
                    set: { newValue in
                        if newValue {
                            storeDetail.usesVouchers.append("온누리 상품권")
                        } else {
                            storeDetail.usesVouchers.removeAll { $0 == "온누리 상품권" }
                        }
                    }
                ))
                
                Toggle("제로페이", isOn: Binding(
                    get: { storeDetail.usesVouchers.contains("제로페이") },
                    set: { newValue in
                        if newValue {
                            storeDetail.usesVouchers.append("제로페이")
                        } else {
                            storeDetail.usesVouchers.removeAll { $0 == "제로페이" }
                        }
                    }
                ))
                
                Toggle("민생회복 소비쿠폰", isOn: Binding(
                    get: { storeDetail.usesVouchers.contains("민생회복 소비쿠폰") },
                    set: { newValue in
                        if newValue {
                            storeDetail.usesVouchers.append("민생회복 소비쿠폰")
                        } else {
                            storeDetail.usesVouchers.removeAll { $0 == "민생회복 소비쿠폰" }
                        }
                    }
                ))
            }
            Section(header: Text("점포 소개")) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { storeDetail.storeDescription },
                        set: { newValue in
                            if newValue.count <= maxCharacters {
                                storeDetail.storeDescription = newValue
                            } else {
                                storeDetail.storeDescription = String(newValue.prefix(maxCharacters))
                            }
                        }
                    ))
                    .frame(height: 150)
                    .focused($isTextFieldFocused)
                    
                    if storeDetail.storeDescription.isEmpty {
                        Text("점포 소개")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }
                }
                HStack {
                    Spacer()
                    Text("\(storeDetail.storeDescription.count)/\(maxCharacters)자")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("점포 등록하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") { isTextFieldFocused = false }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("등록") {
                    Task {
                        let name = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else {
                            lookupAlertMessage = "점포명을 입력해주세요."
                            showLookupAlert = true
                            return
                        }
                        
                        print("[StoreCreateView] appUser.id=\(appUser?.id ?? "nil"), auth.uid=\(Auth.auth().currentUser?.uid ?? "nil")")
                        
                        guard let ownerId = appUser?.id ?? Auth.auth().currentUser?.uid else {
                            lookupAlertMessage = "로그인이 필요합니다."
                            showLookupAlert = true
                            return
                        }
                        let userDocId = ownerId
                        let phone = storeDetail.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                        let addr  = storeDetail.roadAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                        let desc  = storeDetail.storeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        await createVm.createStore(
                            storeName: storeName,
                            categoryId: selectedCategoryId ?? 1,
                            phoneNumber: phone.isEmpty ? nil : phone,
                            weekdayStart: storeDetail.weekdayOpen,
                            weekdayEnd: storeDetail.weekdayClose,
                            weekendStart: storeDetail.weekendOpen,
                            weekendEnd: storeDetail.weekendClose,
                            address: addr.isEmpty ? nil : addr,
                            paymentMethods: storeDetail.usesVouchers,
                            storeDescript: desc.isEmpty ? nil : desc,
                            marketId: selectedMarketID,
                            image: selectedStoreImage.first,
                            ownerId: ownerId,
                            userDocId: userDocId
                        )
                        
                        if createVm.done {
                            dismiss()
                        } else if let msg = createVm.errorMessage {
                            lookupAlertMessage = msg
                            showLookupAlert = true
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(showLookupAlert)
        .alert("알림", isPresented: $showLookupAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(lookupAlertMessage)
        }
        .onAppear { hasStoreVm.stop() }
    }
//    func fromZTimeString(_ str: String) -> Date {
//        let fmt = DateFormatter()
//        fmt.calendar = Calendar(identifier: .gregorian)
//        fmt.locale   = Locale(identifier: "en_US_POSIX")
//        fmt.timeZone = TimeZone(secondsFromGMT: 0)
//        
//        fmt.dateFormat = "HH:mm:ss.SSS'Z'"
//        if let d = fmt.date(from: str) { return d }
//        
//        fmt.dateFormat = "HH:mm:ss'Z'"
//        if let d = fmt.date(from: str) { return d }
//        
//        fmt.dateFormat = "HH:mm:ss"
//        return fmt.date(from: str) ?? Date()
//    }
}
