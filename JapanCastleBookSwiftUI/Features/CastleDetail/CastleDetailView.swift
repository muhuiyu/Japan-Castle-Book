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

private struct CastleDetailInfoView: View {
    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castle: Castle

    private var metadataRows: [(icon: String, value: String)] {
        [
            ("phone", castle.phoneNumber),
            ("clock", castle.openingHours),
            ("mappin", castle.address),
            ("star", "[\(L10n.detailStampLocation)]\n\(castle.stampLocation)")
        ]
    }

    private var imageURLs: [URL] {
        if castle.imageURLs.isEmpty {
            return [URL(string: "https://www.100finecastles.com/wordpress/wp-content/uploads/2013/11/kumamotojo-e1383488845835.jpg")!]
        }

        return castle.imageURLs
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomTrailing) {
                    TabView {
                        ForEach(Array(imageURLs.enumerated()), id: \.offset) { _, url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                default:
                                    Image(AssetImage.castleImagePlaceholder)
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 4)
                        }
                    }
                    .frame(height: 230)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))

                    if experienceStore.hasVisited(castle.id) {
                        Image(AssetImage.doneStamp)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .background(.white)
                            .clipShape(Circle())
                            .padding(.trailing, 12)
                            .padding(.bottom, 10)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("\(castle.id)")
                            .font(.caption.bold())
                            .frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(.primary, lineWidth: 1.5))

                        Text(castle.name)
                            .font(.system(size: 28, weight: .bold))
                            .lineLimit(2)
                    }

                    Text(castle.reading)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(metadataRows, id: \.icon) { row in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: row.icon)
                                .frame(width: 16)
                                .foregroundStyle(.secondary)
                            Text(row.value)
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                detailBlock(title: L10n.detailAccessGuide, value: castle.accessGuide)
                detailBlock(title: L10n.detailOverview, value: castle.overview)

                if !castle.relatedWebsites.isEmpty {
                    relatedWebsitesBlock
                }
            }
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    private func detailBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.horizontal)
    }

    private var relatedWebsitesBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.detailRelatedWebsites)
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(castle.relatedWebsites, id: \.url.absoluteString) { site in
                Link(destination: site.url) {
                    HStack(spacing: 6) {
                        Text(site.name)
                            .font(.body)
                            .foregroundStyle(.mint)
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct CastleDetailLogView: View {
    @EnvironmentObject private var experienceStore: CastleExperienceStore
    @Environment(\.castleStampAssetService) private var stampAssetService

    let castle: Castle
    let didTapAddStamp: () -> Void
    let didTapStamp: () -> Void
    let didTapEditLog: (CastleVisitLogEntry) -> Void
    let didTapDeleteLog: (CastleVisitLogEntry) -> Void

    private var logs: [CastleVisitLogEntry] {
        experienceStore.visitLogs(for: castle.id)
    }

    private var castleStampAssetName: String {
        stampAssetService.stampAssetName(for: castle.id) ?? AssetImage.doneStamp
    }

    var body: some View {
        List {
            stampCard
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if logs.isEmpty {
                emptyLogsCard
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(logs) { log in
                    VisitLogPreviewCard(log: log)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                didTapEditLog(log)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .tint(.mint)

                            Button(role: .destructive) {
                                didTapDeleteLog(log)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }

    private var stampCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.logStampCardTitle)
                .font(.headline)

            Button {
                if experienceStore.hasStamp(castle.id) {
                    didTapStamp()
                } else {
                    didTapAddStamp()
                }
            } label: {
                HStack(spacing: 12) {
                    if let stamp = experienceStore.stampPhoto(for: castle.id) {
                        Image(uiImage: stamp)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if experienceStore.hasStamp(castle.id) {
                        Image(castleStampAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                    } else {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 38, weight: .medium))
                            .frame(width: 72, height: 72)
                            .foregroundStyle(.mint)
                    }

                    Text(experienceStore.hasStamp(castle.id) ? L10n.stampEdit : L10n.logAddStampButton)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyLogsCard: some View {
        VStack(spacing: 12) {
            Text(L10n.logEmptyTitle)
                .font(.headline)
            Text(L10n.logEmptyMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct VisitLogPreviewCard: View {
    let log: CastleVisitLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(log.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(log.title)
                .font(.headline)

            if !log.content.isEmpty {
                Text(log.content)
                    .font(.subheadline)
                    .lineLimit(3)
            }

            if !log.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(log.photos.indices, id: \.self) { index in
                            Image(uiImage: log.photos[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 132, height: 96)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct VisitLogFormView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var draft: CastleDetailView.VisitLogDraft
    let maxPhotos: Int
    let onSelectPhotoSource: (UIImagePickerController.SourceType) -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(L10n.logFormDate, selection: $draft.date, displayedComponents: .date)

                TextField(L10n.logFormVisitTitle, text: $draft.title)

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.logFormVisitContent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $draft.content)
                        .frame(minHeight: 120)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(L10n.logFormAttachPhoto)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(draft.photos.count)/\(maxPhotos)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !draft.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(draft.photos.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: draft.photos[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 128, height: 96)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                        Button {
                                            draft.photos.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white, .black.opacity(0.55))
                                        }
                                        .padding(6)
                                    }
                                }
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                onSelectPhotoSource(.camera)
                            } label: {
                                Label(L10n.sourceCamera, systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(draft.photos.count >= maxPhotos)
                        }

                        Button {
                            onSelectPhotoSource(.photoLibrary)
                        } label: {
                            Label(L10n.sourceLibrary, systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(draft.photos.count >= maxPhotos)
                    }
                }
            }
            .navigationTitle(L10n.logFormTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.logFormSave) {
                        onSave()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
