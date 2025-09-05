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
                                    
            }
            VStack {
                Spacer()
                Button(action: {
                    onSave(name)
                    dismiss()
                }) {
                    Text("완료")
                }
                .buttonStyle(FilledCTA())
                .padding()
            }.padding(.bottom, 10)
        }
        .navigationTitle("점포 이름")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    isTextFieldFocused = false
                }
            }
        }
    }
}

// MARK: - 2) 업종 구분
struct ChangeCategory: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected: StoreCategory
    var onSave: (StoreCategory) -> Void
    
    init(current: StoreCategory?, onSave: ((StoreCategory) -> Void)? = nil) {
        _selected = State(initialValue: current ?? .other)
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            VStack {
                List {
                    ForEach(StoreCategory.allCases) { cat in
                        HStack {
                            Text(cat.displayName)
                            Spacer()
                            if selected == cat {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color("Main"))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selected = cat }
                    }
                }
                Button {
                    onSave(selected)
                    dismiss()
                } label: {
                    Text("완료")
                }
                .buttonStyle(FilledCTA())
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("업종 구분")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 3) 전화번호
struct ChangePhoneNumber: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    var onSave: (String?) -> Void
    
    init(current: String?, onSave: ((String?) -> Void)? = nil) {
        _text = State(initialValue: current ?? "")
        self.onSave = onSave ?? { _ in }
    }
    
    var body: some View {
        ZStack {
            Form {
                TextField("전화번호", text: $text)
                    .keyboardType(.phonePad)
                Section {
                    Button("지우기(없음)") { text = "" }.foregroundStyle(.red)
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(trimmed)
                    dismiss()
                }) {
                    Text("완료")
                }.buttonStyle(FilledCTA())
                    .padding()
            }.padding(.bottom, 10)
        }
        
        .navigationTitle("전화번호")
    }
}

// MARK: - 4) 평일 운영시간
struct ChangeWeekdayHour: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var start: Date?
    @Binding var end: Date?
    var onSave: () -> Void      // 저장은 바인딩된 값을 그대로 사용

    // 기본 시간(09:00 ~ 18:00)
    private let defaultStart = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    private let defaultEnd   = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!

    // 토글: on → 기본값 채움, off → nil
    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { start != nil || end != nil },
            set: { newValue in
                if newValue {
                    if start == nil { start = defaultStart }
                    if end   == nil { end   = defaultEnd }
                } else {
                    start = nil
                    end   = nil
                }
            }
        )
    }

    private var isRangeValid: Bool {
        guard enabledBinding.wrappedValue else { return true }
        guard let s = start, let e = end else { return true }
        return s <= e
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    Toggle("운영시간 등록", isOn: enabledBinding)
                }

                if enabledBinding.wrappedValue {
                    Section("평일 운영 시간") {
                        DatePicker(
                            "시작",
                            selection: Binding<Date>(
                                get: { start ?? defaultStart },
                                set: { start = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "종료",
                            selection: Binding<Date>(
                                get: { end ?? defaultEnd },
                                set: { end = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        if !isRangeValid {
                            Text("시작 시간이 종료 시간보다 늦습니다.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    Section {
                        Button("기본 09:00 ~ 18:00로 설정") {
                            start = defaultStart
                            end   = defaultEnd
                        }
                        Button("지우기(없음)") {
                            start = nil
                            end   = nil
                        }
                        .foregroundStyle(.red)
                    }
                }
            }

            VStack {
                Spacer()
                Button {
                    onSave()     // ← 바인딩된 start/end 그대로 저장
                    dismiss()
                } label: { Text("완료") }
                .buttonStyle(FilledCTA())
                .padding()
                .disabled(!isRangeValid)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle("평일 운영 시간")
    }
}


// MARK: - 5) 주말 운영시간
struct ChangeWeekendHour: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var start: Date?
    @Binding var end: Date?
    var onSave: () -> Void      // 저장은 바인딩된 값을 그대로 사용

    // 기본 시간(09:00 ~ 18:00)
    private let defaultStart = Calendar.current.date(bySettingHour: 9,  minute: 0, second: 0, of: Date())!
    private let defaultEnd   = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!

    // 토글: on → 기본값 채움, off → nil
    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { start != nil || end != nil },
            set: { newValue in
                if newValue {
                    if start == nil { start = defaultStart }
                    if end   == nil { end   = defaultEnd }
                } else {
                    start = nil
                    end   = nil
                }
            }
        )
    }

    private var isRangeValid: Bool {
        guard enabledBinding.wrappedValue else { return true }
        guard let s = start, let e = end else { return true }
        return s <= e
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    Toggle("운영시간 등록", isOn: enabledBinding)
                }

                if enabledBinding.wrappedValue {
                    Section("주말 운영 시간") {
                        DatePicker(
                            "시작",
                            selection: Binding<Date>(
                                get: { start ?? defaultStart },
                                set: { start = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "종료",
                            selection: Binding<Date>(
                                get: { end ?? defaultEnd },
                                set: { end = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        if !isRangeValid {
                            Text("시작 시간이 종료 시간보다 늦습니다.")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    Section {
                        Button("기본 09:00 ~ 18:00로 설정") {
                            start = defaultStart
                            end   = defaultEnd
                        }
                        Button("지우기(없음)") {
                            start = nil
                            end   = nil
                        }
                        .foregroundStyle(.red)
                    }
                }
            }

            VStack {
                Spacer()
                Button {
                    onSave()     // ← 바인딩된 start/end 그대로 저장
                    dismiss()
                } label: { Text("완료") }
                .buttonStyle(FilledCTA())
                .padding()
                .disabled(!isRangeValid)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle("평일 운영 시간")
    }
}
//// MARK: - 6) 도로명 주소
//struct ChangeRoadAddress: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var road: String
//    var onSave: (String?) -> Void
//    
//    init(road: String?, onSave: ((String?) -> Void)? = nil) {
//        _road = State(initialValue: road ?? "")
//        self.onSave = onSave ?? { _ in }
//    }
//    
//    var body: some View {
//        ZStack {
//            Form {
//                TextField("주소", text: $road)
//                Section {
//                    Button("지우기(없음)") { road = "" }.foregroundStyle(.red)
//                }
//            }
//            VStack {
//                Spacer()
//                Button(action: {
//                    let t = road.trimmingCharacters(in: .whitespacesAndNewlines)
//                    onSave(t.isEmpty ? nil : t); dismiss()
//                }) {
//                    Text("완료")
//                }.buttonStyle(FilledCTA())
//                    .padding()
//            }
//            .padding(.bottom, 10)
//        }
//        
//        .navigationTitle("주소")
//    }
//}
//
//// MARK: - 8) 결제 가능 수단
//struct ChangePaymentMethod: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var options: Set<PaymentMethod>
//    var onSave: (Set<PaymentMethod>) -> Void
//    
//    init(paymentOptions: Set<PaymentMethod>,
//         onSave: ((Set<PaymentMethod>) -> Void)? = nil) {
//        _options = State(initialValue: paymentOptions)
//        self.onSave = onSave ?? { _ in }
//    }
//    
//    private func binding(_ m: PaymentMethod) -> Binding<Bool> {
//        Binding(
//            get: { options.contains(m) },
//            set: { isOn in
//                if isOn { _ = options.insert(m) } else { _ = options.remove(m) }
//            }
//        )
//    }
//    
//    var body: some View {
//        ZStack {
//            Form {
//                Toggle("온누리 상품권",  isOn: binding(.onnuriVoucher))
//                Toggle("제로페이",     isOn: binding(.zeropay))
//                Toggle("민생회복 소비쿠폰", isOn: binding(.livelihoodCoupon))
//            }
//            VStack {
//                Spacer()
//                Button(action: {
//                    onSave(options); dismiss()
//                }) {
//                    Text("완료")
//                }.buttonStyle(FilledCTA())
//                    .padding()
//            }
//            .padding(.bottom, 10)
//            
//        }.navigationTitle("결제 가능 수단")
//    }
//}
//
//// MARK: - 9) 점포 소개
//struct ChangeAbout: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var about: String
//    var onSave: (String?) -> Void
//    @State private var count = 0
//    private let maxCharacters = 500
//    
//    init(about: String?, onSave: ((String?) -> Void)? = nil) {
//        _about = State(initialValue: about ?? "")
//        self.onSave = onSave ?? { _ in }
//    }
//    
//    var body: some View {
//        ZStack {
//            Form {
//                ZStack(alignment: .topLeading) {
//                    TextEditor(text: Binding(
//                        get: { about },
//                        set: { newValue in
//                            if newValue.count <= maxCharacters {
//                                about = newValue
//                            } else {
//                                about = String(newValue.prefix(maxCharacters))
//                            }
//                        }
//                    ))
//                    .frame(height: 400)
//                }
//                
//                HStack {
//                    Spacer()
//                    Text("\(about.count)/\(maxCharacters)자")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    
//                }
//            }
//            VStack {
//                Spacer()
//                Button(action: {
//                    let t = about.trimmingCharacters(in: .whitespacesAndNewlines)
//                    onSave(t.isEmpty ? nil : t); dismiss()
//                }) {
//                    Text("완료")
//                }.buttonStyle(FilledCTA())
//                    .padding().background(Color(.systemGray6))
//            }
//        }
//        .navigationTitle("점포 소개")
//        .toolbar {
//            ToolbarItem(placement: .destructiveAction) {
//                Button("지우기") { about = "" }.foregroundStyle(.red)
//            }
//        }
//    }
//}
