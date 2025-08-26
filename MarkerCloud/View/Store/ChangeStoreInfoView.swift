//
//  ChangeStoreInfoView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
//import PhotosUI
//
//enum StoreRoute: Hashable, Identifiable {
//    case nameroute
//    case categoryroute
//    case phoneNumberroute
//    case weekdayHoursroute
//    case weekendHoursroute
//    case addressroute
//    case paymentMethodroute
//    case aboutroute
//    var id: Self { self }
//}
//struct ChangeStoreInfoView: View {
//    let store: Store
//    @State private var photoItem: PhotosPickerItem? = nil
//    @State private var pickedImage: UIImage? = nil
//    
//    @State private var stoereroute: StoreRoute? = nil
//    private let storePromotion = Promotion(name: "점포", imageName: "loginBackground")
//    @State private var pushPromotion: Promotion? = nil
//    @State private var route: Route? = nil
//    @State private var isHoursExpanded = false
//    @State private var isAddressExpanded = false
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                
//                VStack(spacing: 16) {
//                    PhotosPicker(selection: $photoItem, matching: .images) {
//                        ZStack(alignment: .bottomTrailing) {
//                            Group {
//                                if let img = pickedImage {
//                                    Image(uiImage: img)
//                                        .resizable()
//                                        .scaledToFill()
//                                } else {
//                                    AsyncImage(url: store.profileImageURL ?? kDummyImageURL) { phase in
//                                        switch phase {
//                                        case .success(let img): img.resizable().scaledToFill()
//                                        default: Circle().fill(Color(uiColor: .systemGray5))
//                                        }
//                                    }
//                                }
//                            }
//                            .frame(width: 96, height: 96)
//                            .clipShape(Circle())
//                            
//                            Image(systemName: "pencil.circle.fill")
//                                .font(.system(size: 22))
//                                .symbolRenderingMode(.palette)
//                                .foregroundStyle(.white, Color("Main"))
//                                .background(Circle().fill(.white))
//                                .clipShape(Circle())
//                                .offset(x: 4, y: 4)
//                        }
//                    }
//                    .buttonStyle(.plain)
//                    .onChange(of: photoItem) { _, newItem in
//                        guard let item = newItem else { return }
//                        Task {
//                            if let data = try? await item.loadTransferable(type: Data.self),
//                               let uiImg = UIImage(data: data) {
//                                pickedImage = uiImg
//                            }
//                        }
//                    }
//                    
//                    
//                    VStack(spacing: 1) {
//                        Button(action: {
//                            stoereroute = .nameroute
//                        }) {
//                            RowButton(title: "점포 이름",
//                                      value: store.storeName,
//                                      icon: "chevron.right")
//                        }
//                        Button(action: {
//                            stoereroute = .categoryroute
//                        }) {
//                            RowButton(title: "업종 구분",
//                                      value: store.category?.displayName ?? " ",
//                                      icon: "chevron.right")
//                        }
//                        Button(action: {
//                            stoereroute = .phoneNumberroute
//                        }) {
//                            RowButton(title: "전화번호",
//                                      value: store.tel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? " " : store.tel,
//                                      icon: "chevron.right")
//                        }
//                        Button {
//                            withAnimation(.easeInOut) { isHoursExpanded.toggle() }
//                        } label: {
//                            RowButton(title: "운영시간", value: " ",
//                                      icon: isHoursExpanded ? "chevron.down" : "chevron.right")
//                        }
//                        if isHoursExpanded {
//                            VStack(spacing: 0) {
//                                Button { stoereroute = .weekdayHoursroute } label: {
//                                    SubRowButton(title: "평일", value: store.dayOpenTime.map { formattedDate($0) } ?? " ")                                }
//                                Button { stoereroute = .weekendHoursroute } label: {
//                                    SubRowButton(title: "주말", value: store.weekendOpenTime.map { formattedDate($0) } ?? " ")
//                                }
//                            }
//                            .transition(.opacity.combined(with: .move(edge: .top)))
//                            .animation(.easeInOut(duration: 0.25), value: isHoursExpanded)
//                        }
//                        
//                        Button {
//                            stoereroute = .addressroute
//                        } label: {
//                            RowButton(title: "주소", value: store.address.isEmpty ? " " : store.address,
//                                      icon: "chevron.right")
//                        }
////                        Button { stoereroute = .paymentMethodroute } label: {
////                            RowButton(title: "결제 가능 수단",
////                                      value: store.paymentMethods.summary,
////                                      icon: "chevron.right")
////                        }
//                        Button { stoereroute = .aboutroute } label: {
//                            RowButton(title: "점포 소개",
//                                      value: clean(store.description),
//                                      icon: "chevron.right")
//                        }
//                        
//                    }
//                }
//                .padding(16)
//                .background(
//                    RoundedRectangle(cornerRadius: 18, style: .continuous)
//                        .fill(Color.white)
//                )
//                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
//                .padding(.horizontal, 16)
//                
//                Button {
//                    pushPromotion = storePromotion
//                } label: {
//                    Text("점포 홍보 생성하기")
//                        .font(.headline).bold()
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(
//                            RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                .fill(Color("Main"))
//                        )
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 16)
//            }
//            .padding(.top, 8)
//        }
//        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
//        .navigationTitle("내 점포 정보")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(role: .destructive) {
//                    
//                } label: {
//                    Image(systemName: "trash")
//                }
//                .tint(.red)
//            }
//        }
//        .navigationDestination(item: $stoereroute) { r in
//            if stoereroute == .nameroute {
//                ChangeName(name: store.storeName)
//            } else if stoereroute == .categoryroute {
//                ChangeCategory(category: store.category?.rawValue)
//            } else if stoereroute == .phoneNumberroute {
//                ChangePhoneNumber(phoneNumber: store.tel)
//            } else if stoereroute == .weekdayHoursroute {
//                ChangeWeekdayHour(start: store.dayOpenTime, end: store.dayCloseTime)
//            } else if stoereroute == .weekendHoursroute {
//                ChangeWeekendHour(start: store.weekendOpenTime, end: store.weekendCloseTime)
//            } else if stoereroute == .addressroute {
//                ChangeRoadAddress(road: store.address)
//            } else if stoereroute == .paymentMethodroute {
//                ChangePaymentMethod(paymentOptions: store.paymentMethods)
//            } else if stoereroute == .aboutroute {
//                ChangeAbout(about: store.description)
//            }
//        }
//        .navigationDestination(item: $pushPromotion) { promo in
//            PromotionMethodSelectView(promotion: promo)
//        }
//    }
////    private func hhmm(_ t: LocalTime) -> String {
////        var c = DateComponents(); c.hour = t.hour; c.minute = t.minute
////        let d = Calendar.current.date(from: c) ?? Date()
////        let f = DateFormatter(); f.locale = Locale(identifier: "ko_KR"); f.dateFormat = "HH:mm"
////        return f.string(from: d)
////    }
////    private func rangeText(_ r: TimeRange?) -> String {
////        guard let r else { return " " }
////        return "\(hhmm(r.start)) ~ \(hhmm(r.end))"
////    }
//    // 1) 도우미 함수 하나 만들기
//    private func clean(_ s: String?) -> String {
//        let t = s?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        return t.isEmpty ? " " : t
//    }
//    
//    func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
//        return formatter.string(from: date)
//    }
//}
//
//private struct RowButton: View {
//    let title: String
//    let value: String
//    let icon: String
//    
//    var body: some View {
//        HStack {
//            Text(title).font(.body).bold().foregroundColor(.primary)
//            Spacer(minLength: 12)
//            Text(value)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .lineLimit(1)
//            Image(systemName: icon)
//                .font(.footnote)
//                .foregroundStyle(.tertiary)
//        }
//        .frame(minHeight: 46)
//        .contentShape(Rectangle())
//        .padding(.vertical, 6)
//    }
//}
//private struct SubRowButton: View {
//    let title: String
//    let value: String
//    var body: some View {
//        HStack {
//            Image(systemName: "arrow.turn.down.right")
//                .frame(width: 18, alignment: .leading)
//                .foregroundColor(.primary)
//            Text(title).font(.body).foregroundColor(.primary)
//                .frame(width: 90, alignment: .leading)
//            Spacer(minLength: 12)
//            Text(value).font(.body).foregroundColor(.secondary)
//                .frame(width: 160, alignment: .trailing)
//            
//            Spacer()
//            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
//                .frame(width: 12, alignment: .trailing)
//        }
//        .frame(minHeight: 44)
//        .contentShape(Rectangle())
//        .padding(.vertical, 4)
//    }
//}
////extension Set where Element == PaymentMethod {
////    var summary: String {
////        guard !isEmpty else { return " " }
////        return self.map(\.displayName).sorted().joined(separator: ", ")
////    }
////}
//
//private struct StoreImageGrid: View {
//    let url: URL
//    //private let columns = [GridItem(.adaptive(minimum: 90), spacing: 8)]
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "arrow.turn.down.right")
//                .frame(width: 18, alignment: .leading)
//                .foregroundColor(.primary)
//            RemoteThumb(url: url)
//                .frame(width: 110, height: 110, alignment: .leading)
//            Spacer()
//            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
//                .frame(width: 12, alignment: .trailing)
//        }
//        .frame(minHeight: 44)
//        .contentShape(Rectangle())
//        .padding(.vertical, 4)
//        
//    }
//}
//
struct RemoteThumb: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
            case .failure(_):
                Image(systemName: "photo")
                    .resizable().scaledToFit().padding(24)
                    .frame(width: 110, height: 110)
                    .foregroundStyle(.secondary)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            default:
                ProgressView()
                    .frame(width: 110, height: 110)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
