//
//  DetailChangeStoreInfo.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
import PhotosUI

// MARK: - 1) 점포 이름
struct ChangeName: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    var onSave: (String) -> Void
    
    init(name: String, onSave: ((String) -> Void)? = nil) {
        _name = State(initialValue: name)
        self.onSave = onSave ?? { _ in }
    }
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Form {
                TextField("점포 이름", text: $name)
                    .textInputAutocapitalization(.never)
                    .focused($isTextFieldFocused)
                //                    .toolbar {
                //                        ToolbarItemGroup(placement: .keyboard) {
                //                            Spacer()
                //                            Button("완료") {
                //                                isTextFieldFocused = false
                //                            }
                //                        }
                //                    }
            }
            VStack {
                Spacer()
                Button(action: {
                    onSave(name)
                    dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    //                            .fontWeight(.bold)
                    //                            .foregroundColor(.white)
                    //                            .frame(maxWidth: .infinity)
                    //                            .padding()
                    //                            .background(Color("Main"))
                }
            }.padding(.bottom, 10)
        }
        .navigationTitle("점포 이름")
    }
}

// MARK: - 2) 업종 구분
struct ChangeCategory: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: StoreCategory?
    var onSave: (StoreCategory?) -> Void
    
    init(category: StoreCategory?, onSave: ((StoreCategory?) -> Void)? = nil) {
        _category = State(initialValue: category)
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(StoreCategory.allCases) { c in
                    HStack {
                        Text(c.displayName)
                        Spacer()
                        if c == category { Image(systemName: "checkmark") }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { category = c }
                }
                Section {
                    Button("지우기(없음)") { category = nil }
                        .foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    onSave(category)
                    dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 10)
        }
        
        .navigationTitle("업종 구분")
    }
}

// MARK: - 3) 전화번호
struct ChangePhoneNumber: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phone: String
    var onSave: (String?) -> Void
    
    init(phoneNumber: String?, onSave: ((String?) -> Void)? = nil) {
        _phone = State(initialValue: phoneNumber ?? "")
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            Form {
                TextField("전화번호", text: $phone)
                    .keyboardType(.phonePad)
                Section {
                    Button("지우기(없음)") { phone = "" }.foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(trimmed.isEmpty ? nil : trimmed)
                    dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }.padding(.bottom, 10)
        }
        
        .navigationTitle("전화번호")
    }
}

// MARK: - 4) 평일 운영시간
struct ChangeWeekdayHour: View {
    @Environment(\.dismiss) private var dismiss
    @State private var start: Date?
    @State private var end: Date?
    init(start: Date? = nil, end: Date? = nil) {
            _start = State(initialValue: start)
            _end = State(initialValue: end)
        }
    
    var body: some View {
        ZStack {
            Form {
                Section("평일 운영 시간") {
                    DatePicker(
                                "시작",
                                selection: Binding(
                                    get: { start ?? Date() },
                                    set: { start = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )

                            DatePicker(
                                "종료",
                                selection: Binding(
                                    get: { end ?? Date() },
                                    set: { end = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                }
                Section {
                    Button("지우기(없음)") {
                        //onSave(nil);
                        dismiss() }.foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    //onSave(TimeRange(start: localTime(from: start), end: localTime(from: end)))
                    dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                }
            }.padding(.bottom, 10)
        }
        .navigationTitle("평일 운영 시간")
    }
}

// MARK: - 5) 주말 운영시간
struct ChangeWeekendHour: View {
    @Environment(\.dismiss) private var dismiss
    @State private var start: Date?
    @State private var end: Date?
    init(start: Date? = nil, end: Date? = nil) {
            _start = State(initialValue: start)
            _end = State(initialValue: end)
        }
    
    var body: some View {
        ZStack {
            Form {
                Section("주말 운영 시간") {
                    DatePicker(
                                "시작",
                                selection: Binding(
                                    get: { start ?? Date() },
                                    set: { start = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )

                            DatePicker(
                                "종료",
                                selection: Binding(
                                    get: { end ?? Date() },
                                    set: { end = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                }
                Section {
                    Button("지우기(없음)") {
                        //onSave(nil);
                        dismiss() }.foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    //onSave(TimeRange(start: localTime(from: start), end: localTime(from: end)))
                    dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 10)
        }
        
        .navigationTitle("주말 운영 시간")
    }
}

// MARK: - 6) 도로명 주소
struct ChangeRoadAddress: View {
    @Environment(\.dismiss) private var dismiss
    @State private var road: String
    var onSave: (String?) -> Void
    
    init(road: String?, onSave: ((String?) -> Void)? = nil) {
        _road = State(initialValue: road ?? "")
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            Form {
                TextField("주소", text: $road)
                Section {
                    Button("지우기(없음)") { road = "" }.foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    let t = road.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(t.isEmpty ? nil : t); dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 10)
        }
        
        .navigationTitle("주소")
    }
}

// MARK: - 8) 결제 가능 수단
struct ChangePaymentMethod: View {
    @Environment(\.dismiss) private var dismiss
    @State private var options: Set<PaymentMethod>
    var onSave: (Set<PaymentMethod>) -> Void
    
    init(paymentOptions: Set<PaymentMethod>,
         onSave: ((Set<PaymentMethod>) -> Void)? = nil) {
        _options = State(initialValue: paymentOptions)
        self.onSave = onSave ?? { _ in }
    }
    
    private func binding(_ m: PaymentMethod) -> Binding<Bool> {
        Binding(
            get: { options.contains(m) },
            set: { isOn in
                if isOn { _ = options.insert(m) } else { _ = options.remove(m) }
            }
        )
    }
    
    var body: some View {
        ZStack {
            Form {
                Toggle("온누리상품권",  isOn: binding(.onnuriVoucher))
                Toggle("제로페이",     isOn: binding(.zeropay))
                Toggle("민생회복쿠폰", isOn: binding(.livelihoodCoupon))
            }
            VStack {
                Spacer()
                Button(action: {
                    onSave(options); dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 10)
            
        }.navigationTitle("결제 가능 수단")
    }
}

// MARK: - 9) 점포 소개
struct ChangeAbout: View {
    @Environment(\.dismiss) private var dismiss
    @State private var about: String
    var onSave: (String?) -> Void
    @State private var count = 0
    private let maxCharacters = 500
    
    init(about: String?, onSave: ((String?) -> Void)? = nil) {
        _about = State(initialValue: about ?? "")
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            Form {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { about },
                        set: { newValue in
                            if newValue.count <= maxCharacters {
                                about = newValue
                            } else {
                                about = String(newValue.prefix(maxCharacters))
                            }
                        }
                    ))
                    .frame(height: 400)
                }
                
                HStack {
                    Spacer()
                    Text("\(about.count)/\(maxCharacters)자")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    let t = about.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(t.isEmpty ? nil : t); dismiss()
                }) {
                    Text("완료")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.body)
                        .padding()
                        .background(Color("Main"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    //                            .fontWeight(.bold)
                    //                            .foregroundColor(.white)
                    //                            .frame(maxWidth: .infinity)
                    //                            .padding()
                    //                            .background(Color("Main"))
                }
            }.padding(.bottom, 10)
        }
        .navigationTitle("점포 소개")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("지우기") { about = "" }.foregroundStyle(.red)
            }
        }
    }
}
