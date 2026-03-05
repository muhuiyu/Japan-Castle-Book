import Foundation
import JapanCastleBook
import SwiftUI
import UIKit

struct CastleDetailView: View {
    private enum DialogAnchor {
        case root
        case completeButton
    }

    private enum Segment: String, CaseIterable {
        case info
        case visitLog

        var title: String {
            switch self {
            case .info:
                return L10n.detailSegmentInfo
            case .visitLog:
                return L10n.detailSegmentVisitLog
            }
        }
    }

    private enum PickerPurpose {
        case quickLog
        case stamp
        case visitLog
    }

    private struct ActivePicker: Identifiable {
        let id = UUID()
        let purpose: PickerPurpose
        let sourceType: UIImagePickerController.SourceType
    }

    struct VisitLogDraft {
        var date = Date()
        var title = ""
        var content = ""
        var photos: [UIImage] = []
    }

    private static let maxVisitLogPhotos = 6

    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castle: Castle

    @State private var selectedSegment: Segment = .info

    @State private var showingCompleteActions = false
    @State private var showingStampActions = false
    @State private var showingStampEditActions = false
    @State private var showingImageSourceActions = false
    @State private var showingVisitLogForm = false

    @State private var stampDialogAnchor: DialogAnchor = .root
    @State private var imageSourceDialogAnchor: DialogAnchor = .root

    @State private var imageSourcePurpose: PickerPurpose = .quickLog
    @State private var activePicker: ActivePicker?
    @State private var shouldReopenVisitLogFormAfterPicker = false

    @State private var visitLogDraft = VisitLogDraft()
    @State private var editingVisitLogID: UUID?
    @State private var toastMessage: String?
    @State private var toastID = UUID()

    var body: some View {
        VStack(spacing: 12) {
            Picker("Section", selection: $selectedSegment) {
                ForEach(Segment.allCases, id: \.self) { segment in
                    Text(segment.title).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Group {
                switch selectedSegment {
                case .info:
                    CastleDetailInfoView(castle: castle)
                case .visitLog:
                    CastleDetailLogView(
                        castle: castle,
                        didTapAddStamp: handleAddStampTapped,
                        didTapStamp: handleStampTapped,
                        didTapEditLog: beginEditing(log:),
                        didTapDeleteLog: delete(log:)
                    )
                }
            }

            Button {
                showingCompleteActions = true
            } label: {
                Text(L10n.detailComplete)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.mint)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .confirmationDialog(L10n.completeChooseAction, isPresented: $showingCompleteActions) {
                Button(L10n.actionTakePhoto) {
                    imageSourcePurpose = .quickLog
                    imageSourceDialogAnchor = .completeButton
                    showingImageSourceActions = true
                }
                Button(L10n.actionAddStamp) {
                    stampDialogAnchor = .completeButton
                    showingStampActions = true
                }
                Button(L10n.actionAddVisitLog) {
                    editingVisitLogID = nil
                    visitLogDraft = VisitLogDraft()
                    showingVisitLogForm = true
                }
                Button(L10n.cancel, role: .cancel) {}
            }
            .confirmationDialog(L10n.stampChooseAction, isPresented: showingStampActionsFromComplete) {
                stampActionsButtons
            }
            .confirmationDialog(L10n.sourceChooseAction, isPresented: showingImageSourceActionsFromComplete) {
                imageSourceButtons
            }
        }
        .navigationTitle(castle.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(L10n.stampChooseAction, isPresented: showingStampActionsFromRoot) {
            stampActionsButtons
        }
        .confirmationDialog(L10n.stampEdit, isPresented: $showingStampEditActions) {
            Button(L10n.stampRemove, role: .destructive) {
                experienceStore.removeStamp(for: castle.id)
            }
            Button(L10n.stampTakePhoto) {
                imageSourcePurpose = .stamp
                imageSourceDialogAnchor = .root
                showingImageSourceActions = true
            }
            Button(L10n.cancel, role: .cancel) {}
        }
        .confirmationDialog(L10n.sourceChooseAction, isPresented: showingImageSourceActionsFromRoot) {
            imageSourceButtons
        }
        .sheet(item: $activePicker) { picker in
            ImagePicker(sourceType: picker.sourceType) { image in
                handlePickedImage(image, purpose: picker.purpose)
            } onCancel: {
                handlePickerCancelled(purpose: picker.purpose)
            }
        }
        .sheet(isPresented: $showingVisitLogForm) {
            VisitLogFormView(
                draft: $visitLogDraft,
                maxPhotos: Self.maxVisitLogPhotos,
                onSelectPhotoSource: { sourceType in
                    shouldReopenVisitLogFormAfterPicker = true
                    showingVisitLogForm = false
                    DispatchQueue.main.async {
                        activePicker = ActivePicker(purpose: .visitLog, sourceType: sourceType)
                    }
                },
                onSave: {
                    let title = visitLogDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let content = visitLogDraft.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }

                    if let editingVisitLogID {
                        experienceStore.updateVisitLog(
                            for: castle.id,
                            logID: editingVisitLogID,
                            date: visitLogDraft.date,
                            title: title,
                            content: content,
                            photos: visitLogDraft.photos
                        )
                    } else {
                        experienceStore.addVisitLog(
                            for: castle.id,
                            date: visitLogDraft.date,
                            title: title,
                            content: content,
                            photos: visitLogDraft.photos
                        )
                    }
                    showToast(L10n.toastVisitLogAdded)
                    editingVisitLogID = nil
                    showingVisitLogForm = false
                    selectedSegment = .visitLog
                }
            )
        }
        .overlay(alignment: .bottom) {
            if let toastMessage {
                Text(toastMessage)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.bottom, 80)
                    .transition(.opacity)
            }
        }
    }

    private func handleAddStampTapped() {
        if experienceStore.hasStamp(castle.id) {
            showingStampEditActions = true
        } else {
            stampDialogAnchor = .root
            showingStampActions = true
        }
    }

    private func handleStampTapped() {
        guard experienceStore.hasStamp(castle.id) else { return }
        showingStampEditActions = true
    }

    private func handlePickedImage(_ image: UIImage, purpose: PickerPurpose) {
        switch purpose {
        case .quickLog:
            experienceStore.addVisitLog(
                for: castle.id,
                date: Date(),
                title: L10n.actionTakePhoto,
                content: "",
                photos: [image]
            )
            showToast(L10n.toastPhotoAdded)
            selectedSegment = .visitLog
        case .stamp:
            experienceStore.setStampPhoto(for: castle.id, image: image)
            showToast(L10n.toastStampPhotoAdded)
        case .visitLog:
            if visitLogDraft.photos.count < Self.maxVisitLogPhotos {
                visitLogDraft.photos.append(image)
            }
            shouldReopenVisitLogFormAfterPicker = false
            showingVisitLogForm = true
        }
    }

    private func handlePickerCancelled(purpose: PickerPurpose) {
        if purpose == .visitLog && shouldReopenVisitLogFormAfterPicker {
            shouldReopenVisitLogFormAfterPicker = false
            showingVisitLogForm = true
        }
    }

    private func beginEditing(log: CastleVisitLogEntry) {
        editingVisitLogID = log.id
        visitLogDraft = VisitLogDraft(
            date: log.date,
            title: log.title,
            content: log.content,
            photos: log.photos
        )
        showingVisitLogForm = true
    }

    private func delete(log: CastleVisitLogEntry) {
        experienceStore.removeVisitLog(for: castle.id, logID: log.id)
    }

    private var showingStampActionsFromComplete: Binding<Bool> {
        Binding(
            get: { showingStampActions && stampDialogAnchor == .completeButton },
            set: { isPresented in
                if !isPresented && stampDialogAnchor == .completeButton {
                    showingStampActions = false
                }
            }
        )
    }

    private var showingStampActionsFromRoot: Binding<Bool> {
        Binding(
            get: { showingStampActions && stampDialogAnchor == .root },
            set: { isPresented in
                if !isPresented && stampDialogAnchor == .root {
                    showingStampActions = false
                }
            }
        )
    }

    private var showingImageSourceActionsFromComplete: Binding<Bool> {
        Binding(
            get: { showingImageSourceActions && imageSourceDialogAnchor == .completeButton },
            set: { isPresented in
                if !isPresented && imageSourceDialogAnchor == .completeButton {
                    showingImageSourceActions = false
                }
            }
        )
    }

    private var showingImageSourceActionsFromRoot: Binding<Bool> {
        Binding(
            get: { showingImageSourceActions && imageSourceDialogAnchor == .root },
            set: { isPresented in
                if !isPresented && imageSourceDialogAnchor == .root {
                    showingImageSourceActions = false
                }
            }
        )
    }

    @ViewBuilder
    private var stampActionsButtons: some View {
        Button(L10n.stampAddDigital) {
            experienceStore.addDigitalStamp(for: castle.id)
            showToast(L10n.toastStampAdded)
        }
        Button(L10n.stampTakePhoto) {
            imageSourcePurpose = .stamp
            imageSourceDialogAnchor = stampDialogAnchor
            showingImageSourceActions = true
        }
        Button(L10n.cancel, role: .cancel) {}
    }

    @ViewBuilder
    private var imageSourceButtons: some View {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            Button(L10n.sourceCamera) {
                activePicker = ActivePicker(purpose: imageSourcePurpose, sourceType: .camera)
            }
        }
        Button(L10n.sourceLibrary) {
            activePicker = ActivePicker(purpose: imageSourcePurpose, sourceType: .photoLibrary)
        }
        Button(L10n.cancel, role: .cancel) {}
    }

    private func showToast(_ message: String) {
        let currentID = UUID()
        toastID = currentID

        withAnimation(.easeInOut(duration: 0.2)) {
            toastMessage = message
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                guard toastID == currentID else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    toastMessage = nil
                }
            }
        }
    }
}

#Preview {
    CastleDetailView(
        castle: Castle(
            id: 1,
            name: "根室半島チャシ跡群",
            reading: "ねむろはんとうちゃしあとぐん",
            area: .hokkaidoTohoku,
            address: "Hokkaido",
            phoneNumber: "0000",
            openingHours: "9:00 - 17:00",
            accessGuide: "Walk from station.",
            parkingInfo: "Available",
            stampLocation: "Visitor center",
            overview: "A historic site.",
            imageURLs: []
        )
    )
    .environmentObject(CastleExperienceStore())
}
