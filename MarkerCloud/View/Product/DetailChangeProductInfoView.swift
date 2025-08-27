////
////  DetailChangeStoreInfo.swift
////  MarkerCloud
////
////  Created by 이민서 on 8/17/25.
////
//
//import SwiftUI
//import PhotosUI
//
//// MARK: - 1) 상품 이름
//struct ChangeproductName: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var name: String
//    var onSave: (String) -> Void
//    
//    init(name: String, onSave: ((String) -> Void)? = nil) {
//        _name = State(initialValue: name)
//        self.onSave = onSave ?? { _ in }
//    }
//    @FocusState private var isTextFieldFocused: Bool
//    
//    var body: some View {
//        ZStack {
//            Form {
//                TextField("상품 이름", text: $name)
//                    .textInputAutocapitalization(.never)
//                    .focused($isTextFieldFocused)
//            }
//            VStack {
//                Spacer()
//                Button(action: {
//                    onSave(name)
//                    dismiss()
//                }) {
//                    Text("완료")
//                }
//                .buttonStyle(FilledCTA())
//                .padding()
//            }.padding(.bottom, 10)
//        }
//        .navigationTitle("상품 이름")
//    }
//}
//
//// MARK: - 2) 상품 내용
//struct ChangeproductMemo: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var productMemo: String
//    var onSave: (String?) -> Void
//    @State private var count = 0
//    private let maxCharacters = 500
//
//    init(productMemo: String?, onSave: ((String?) -> Void)? = nil) {
//        _productMemo = State(initialValue: productMemo ?? "")
//        self.onSave = onSave ?? { _ in }
//    }
//
//    var body: some View {
//        ZStack {
//            Form {
//                ZStack(alignment: .topLeading) {
//                    TextEditor(text: Binding(
//                        get: { productMemo },
//                        set: { newValue in
//                            if newValue.count <= maxCharacters {
//                                productMemo = newValue
//                            } else {
//                                productMemo = String(newValue.prefix(maxCharacters))
//                            }
//                        }
//                    ))
//                    .frame(height: 400)
//                }
//
//                HStack {
//                    Spacer()
//                    Text("\(productMemo.count)/\(maxCharacters)자")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//
//                }
//            }
//            VStack {
//                Spacer()
//                Button(action: {
//                    let t = productMemo.trimmingCharacters(in: .whitespacesAndNewlines)
//                    onSave(t.isEmpty ? nil : t); dismiss()
//                }) {
//                    Text("완료")
//               }
//                .buttonStyle(FilledCTA())
//                .padding()
//            }.padding(.bottom, 10)
//        }
//        .navigationTitle("상품 내용")
//        .toolbar {
//            ToolbarItem(placement: .destructiveAction) {
//                Button("지우기") { productMemo = "" }.foregroundStyle(.red)
//            }
//        }
//    }
//}
