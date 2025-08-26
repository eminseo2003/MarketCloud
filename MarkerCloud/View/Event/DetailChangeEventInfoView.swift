//
//  ChangeEventName.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/20/25.
//

import SwiftUI

// MARK: - 1) 이벤트 이름
struct ChangeEventName: View {
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
                TextField("이벤트 이름", text: $name)
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
        .navigationTitle("이벤트 이름")
    }
}

// MARK: - 2) 이벤트 내용
struct ChangeEventMemo: View {
    @Environment(\.dismiss) private var dismiss
    @State private var eventMemo: String
    var onSave: (String?) -> Void
    @State private var count = 0
    private let maxCharacters = 500

    init(eventMemo: String?, onSave: ((String?) -> Void)? = nil) {
        _eventMemo = State(initialValue: eventMemo ?? "")
        self.onSave = onSave ?? { _ in }
    }

    var body: some View {
        ZStack {
            Form {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { eventMemo },
                        set: { newValue in
                            if newValue.count <= maxCharacters {
                                eventMemo = newValue
                            } else {
                                eventMemo = String(newValue.prefix(maxCharacters))
                            }
                        }
                    ))
                    .frame(height: 400)
                }

                HStack {
                    Spacer()
                    Text("\(eventMemo.count)/\(maxCharacters)자")
                        .font(.caption)
                        .foregroundColor(.gray)

                }
            }
            VStack {
                Spacer()
                Button(action: {
                    let t = eventMemo.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(t.isEmpty ? nil : t); dismiss()
                }) {
                    Text("완료")
               }
                .buttonStyle(FilledCTA())
                .padding()
            }.padding(.bottom, 10)
        }
        .navigationTitle("이벤트 내용")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("지우기") { eventMemo = "" }.foregroundStyle(.red)
            }
        }
    }
}
