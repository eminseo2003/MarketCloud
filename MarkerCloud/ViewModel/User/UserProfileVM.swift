//
//  UserProfileVM.swift
//  MarkerCloud
//
//  Created by 이민서 on 9/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import OSLog
import UIKit

@MainActor
final class UserProfileVM: ObservableObject {
    @Published var isLoading = false
    @Published var isSaving  = false
    @Published var errorMessage: String?

    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var profileURL: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MarkerCloud",
                             category: "UserProfileVM")

    func load(userId: String) async {
        guard !userId.isEmpty else { return }
        isLoading = true; errorMessage = nil
        do {
            let snap = try await db.collection("users").document(userId).getDocument()
            let data = snap.data() ?? [:]
            self.userName  = data["userName"] as? String ?? ""
            self.email     = data["email"] as? String ?? ""
            self.profileURL = data["profileURL"] as? String
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            log.error("load error: \(error.localizedDescription, privacy: .public)")
        }
    }

    func save(userId: String, pickedImage: UIImage?) async {
        guard !userId.isEmpty else { return }
        isSaving = true; errorMessage = nil
        defer { isSaving = false }

        var newURL = self.profileURL

        if let img = pickedImage, let data = img.jpegData(compressionQuality: 0.85) {
            do {
                let ref = storage.reference().child("user_profiles/\(userId).jpg")
                let meta = StorageMetadata()
                meta.contentType = "image/jpeg"
                _ = try await ref.putDataAsync(data, metadata: meta)
                newURL = try await ref.downloadURLAsync().absoluteString
            } catch {
                errorMessage = "프로필 사진 업로드 실패: \(error.localizedDescription)"
                return
            }
        }

        do {
            var update: [String: Any] = [
                "userName": self.userName,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            if let newURL { update["profileURL"] = newURL }
            try await db.collection("users").document(userId).setData(update, merge: true)
            self.profileURL = newURL
        } catch {
            errorMessage = "프로필 저장 실패: \(error.localizedDescription)"
        }
    }

    func removePhoto(userId: String) async {
        guard !userId.isEmpty else { return }
        isSaving = true; defer { isSaving = false }
        do {
            try await db.collection("users").document(userId)
                .setData(["profileURL": FieldValue.delete(),
                          "updatedAt": FieldValue.serverTimestamp()], merge: true)
            self.profileURL = nil
        } catch {
            errorMessage = "사진 제거 실패: \(error.localizedDescription)"
        }
    }
}

extension StorageReference {
    func putDataAsync(_ data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { cont in
            self.putData(data, metadata: metadata) { meta, err in
                if let err = err { cont.resume(throwing: err) }
                else { cont.resume(returning: meta ?? StorageMetadata()) }
            }
        }
    }
    func downloadURLAsync() async throws -> URL {
        try await withCheckedThrowingContinuation { cont in
            self.downloadURL { url, err in
                if let err = err { cont.resume(throwing: err) }
                else { cont.resume(returning: url!) }
            }
        }
    }
}

