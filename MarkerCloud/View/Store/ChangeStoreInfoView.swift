//
//  ChangeStoreInfoView.swift
//  MarkerCloud
//
//  Created by 이민서 on 8/17/25.
//

import SwiftUI
import PhotosUI

func displayName(for categoryId: Int?) -> String {
    guard let id = categoryId, let cat = StoreCategory(rawValue: id) else { return " " }
    return cat.displayName
}
enum StoreRoute: Hashable, Identifiable {
    case nameroute
    case categoryroute
    case phoneNumberroute
    case weekdayHoursroute
    case weekendHoursroute
    case addressroute
    case paymentMethodroute
    case aboutroute
    var id: Self { self }
}
struct ChangeStoreInfoView: View {
    let storeId: String
    let appUser: AppUser?
    @Binding var selectedMarketID: Int
    @StateObject private var storeVm = StoreVM()
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage? = nil
    
    @State private var stoereroute: StoreRoute? = nil
    private let storePromotion = Promotion(name: "점포", imageName: "loginBackground")
    @State private var pushPromotion: Promotion? = nil
    @State private var route: Route? = nil
    @State private var isHoursExpanded = false
    @State private var isAddressExpanded = false
    
    var body: some View {
        ScrollView {
            if storeVm.isLoading {
                ProgressView("불러오는 중…").padding(.top, 24)
            } else if let err = storeVm.errorMessage {
                VStack(spacing: 8) {
                    Text("불러오기 실패").font(.headline)
                    Text(err).foregroundColor(.secondary).font(.caption)
                    Button("다시 시도") { Task { await storeVm.load(storeId: storeId) } }
                }
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 16) {
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let img = pickedImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        AsyncImage(url: URL(string: storeVm.profileImageURL ?? "")) { phase in
                                            switch phase {
                                            case .success(let img): img.resizable().scaledToFill()
                                            default: Circle().fill(Color(uiColor: .systemGray5))
                                            }
                                        }
                                    }
                                }
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 22))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, Color("Main"))
                                    .background(Circle().fill(.white))
                                    .clipShape(Circle())
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: photoItem) { _, newItem in
                            guard let item = newItem else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImg = UIImage(data: data) {
                                    pickedImage = uiImg
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        
                        VStack(spacing: 1) {
                            Button(action: {
                                stoereroute = .nameroute
                            }) {
                                RowButton(title: "점포 이름",
                                          value: storeVm.storeName,
                                          icon: "chevron.right")
                            }
                            Button(action: {
                                stoereroute = .categoryroute
                            }) {
                                RowButton(title: "업종 구분",
                                          value: displayName(for: storeVm.categoryId),
                                          icon: "chevron.right")
                            }
                            Button(action: {
                                stoereroute = .phoneNumberroute
                            }) {
                                RowButton(title: "전화번호",
                                          value: storeVm.phoneNumber ?? " ",
                                          icon: "chevron.right")
                            }
                            Button {
                                withAnimation(.easeInOut) { isHoursExpanded.toggle() }
                            } label: {
                                RowButton(title: "운영시간", value: " ",
                                          icon: isHoursExpanded ? "chevron.down" : "chevron.right")
                            }
                            if isHoursExpanded {
                                VStack(spacing: 0) {
                                    Button { stoereroute = .weekdayHoursroute } label: {
                                        SubRowButton(title: "평일", value: timeRangeText(storeVm.weekdayStart, storeVm.weekdayEnd))
                                    }
                                    Button { stoereroute = .weekendHoursroute } label: {
                                        SubRowButton(title: "주말", value: timeRangeText(storeVm.weekendStart, storeVm.weekendEnd))
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .animation(.easeInOut(duration: 0.25), value: isHoursExpanded)
                            }
                            Button {
                                stoereroute = .addressroute
                            } label: {
                                RowButton(title: "주소", value: storeVm.address ?? " ",
                                          icon: "chevron.right")
                            }
                            Button {
                                stoereroute = .paymentMethodroute
                            } label: {
                                RowButton(title: "결제 가능 수단",
                                          value: storeVm.paymentSummary,
                                          icon: "chevron.right")
                            }
                            Button { stoereroute = .aboutroute } label: {
                                RowButton(title: "점포 소개",
                                          value: clean(storeVm.storeDescript ?? ""),
                                          icon: "chevron.right")
                            }
                            
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    
                    Button {
                        pushPromotion = storePromotion
                    } label: {
                        Text("점포 홍보 생성하기")
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color("Main"))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .padding(.top, 8)
                
            }
        }
        .background(Color(uiColor: .systemGray6).ignoresSafeArea())
        .navigationTitle("내 점포 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
        }
        .task(id: storeId) {
            await storeVm.load(storeId: storeId)
        }
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
//        }.background(Color(.systemGray6))
        .navigationDestination(item: $pushPromotion) { promo in
            PromotionMethodSelectView(promotion: promo, appUser: appUser, selectedMarketID: $selectedMarketID)
        }
    }
    private func clean(_ s: String?) -> String {
        let t = s?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return t.isEmpty ? " " : t
    }
    private let hhmmFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "HH:mm"
        return f
    }()

    private func timeRangeText(_ start: Date?, _ end: Date?) -> String {
        switch (start, end) {
        case (nil, nil): return "미등록"
        case (let s?, nil): return "\(hhmmFormatter.string(from: s)) ~"
        case (nil, let e?): return "~ \(hhmmFormatter.string(from: e))"
        case (let s?, let e?): return "\(hhmmFormatter.string(from: s)) ~ \(hhmmFormatter.string(from: e))"
        }
    }

}

private struct RowButton: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(title).font(.body).bold().foregroundColor(.primary)
            Spacer(minLength: 12)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(1)
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(minHeight: 46)
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
}
private struct SubRowButton: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Image(systemName: "arrow.turn.down.right")
                .frame(width: 18, alignment: .leading)
                .foregroundColor(.primary)
            Text(title).font(.body).foregroundColor(.primary)
                .frame(width: 90, alignment: .leading)
            Spacer(minLength: 12)
            Text(value).font(.body).foregroundColor(.secondary)
                .frame(width: 160, alignment: .trailing)
            
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
                .frame(width: 12, alignment: .trailing)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

private struct StoreImageGrid: View {
    let url: URL
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.turn.down.right")
                .frame(width: 18, alignment: .leading)
                .foregroundColor(.primary)
            RemoteThumb(url: url.absoluteString)
                .frame(width: 110, height: 110, alignment: .leading)
            Spacer()
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
                .frame(width: 12, alignment: .trailing)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .padding(.vertical, 4)
        
    }
}

struct RemoteThumb: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
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
