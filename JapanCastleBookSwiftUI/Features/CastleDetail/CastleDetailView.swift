import Foundation
import JapanCastleBook
import SwiftUI
import UIKit

struct CastleDetailView: View {
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
        var photo: UIImage?
    }

    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castle: Castle

    @State private var selectedSegment: Segment = .info

    @State private var showingCompleteActions = false
    @State private var showingStampActions = false
    @State private var showingStampEditActions = false
    @State private var showingImageSourceActions = false
    @State private var showingVisitLogForm = false

    @State private var imageSourcePurpose: PickerPurpose = .quickLog
    @State private var activePicker: ActivePicker?

    @State private var visitLogDraft = VisitLogDraft()

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
                        didTapStamp: handleStampTapped
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
        }
        .navigationTitle(castle.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(L10n.completeChooseAction, isPresented: $showingCompleteActions) {
            Button(L10n.actionTakePhoto) {
                imageSourcePurpose = .quickLog
                showingImageSourceActions = true
            }
            Button(L10n.actionAddStamp) {
                showingStampActions = true
            }
            Button(L10n.actionAddVisitLog) {
                visitLogDraft = VisitLogDraft()
                showingVisitLogForm = true
            }
            Button(L10n.cancel, role: .cancel) {}
        }
        .confirmationDialog(L10n.stampChooseAction, isPresented: $showingStampActions) {
            Button(L10n.stampAddDigital) {
                experienceStore.addDigitalStamp(for: castle.id)
            }
            Button(L10n.stampTakePhoto) {
                imageSourcePurpose = .stamp
                showingImageSourceActions = true
            }
            Button(L10n.cancel, role: .cancel) {}
        }
        .confirmationDialog(L10n.stampEdit, isPresented: $showingStampEditActions) {
            Button(L10n.stampRemove, role: .destructive) {
                experienceStore.removeStamp(for: castle.id)
            }
            Button(L10n.stampTakePhoto) {
                imageSourcePurpose = .stamp
                showingImageSourceActions = true
            }
            Button(L10n.cancel, role: .cancel) {}
        }
        .confirmationDialog(L10n.sourceChooseAction, isPresented: $showingImageSourceActions) {
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
        .sheet(item: $activePicker) { picker in
            ImagePicker(sourceType: picker.sourceType) { image in
                handlePickedImage(image, purpose: picker.purpose)
            }
        }
        .sheet(isPresented: $showingVisitLogForm) {
            VisitLogFormView(
                draft: $visitLogDraft,
                onAttachPhoto: {
                    imageSourcePurpose = .visitLog
                    showingImageSourceActions = true
                },
                onSave: {
                    let title = visitLogDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    let content = visitLogDraft.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }

                    experienceStore.addVisitLog(
                        for: castle.id,
                        date: visitLogDraft.date,
                        title: title,
                        content: content,
                        photo: visitLogDraft.photo
                    )
                    showingVisitLogForm = false
                    selectedSegment = .visitLog
                }
            )
        }
    }

    private func handleAddStampTapped() {
        if experienceStore.hasStamp(castle.id) {
            showingStampEditActions = true
        } else {
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
                photo: image
            )
            selectedSegment = .visitLog
        case .stamp:
            experienceStore.setStampPhoto(for: castle.id, image: image)
        case .visitLog:
            visitLogDraft.photo = image
            showingVisitLogForm = true
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
                        ForEach(imageURLs, id: \.self) { url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                default:
                                    Image("castle-image-placeholder")
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
                        Image("done-stamp")
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
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                detailBlock(title: L10n.detailAccessGuide, value: castle.accessGuide)
                detailBlock(title: L10n.detailOverview, value: castle.overview)
            }
            .padding(.bottom, 12)
        }
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
}

private struct CastleDetailLogView: View {
    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castle: Castle
    let didTapAddStamp: () -> Void
    let didTapStamp: () -> Void

    private var logs: [CastleVisitLogEntry] {
        experienceStore.visitLogs(for: castle.id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                stampCard

                if logs.isEmpty {
                    emptyLogsCard
                } else {
                    ForEach(logs) { log in
                        VisitLogPreviewCard(log: log)
                    }
                }
            }
            .padding()
        }
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
                        Image("done-stamp")
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
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyLogsCard: some View {
        VStack(spacing: 12) {
            Image("done-stamp")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .opacity(0.15)

            Text(L10n.logEmptyTitle)
                .font(.headline)
            Text(L10n.logEmptyMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
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

            if let photo = log.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
    let onAttachPhoto: () -> Void
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(L10n.logFormDate, selection: $draft.date, displayedComponents: .date)

                TextField(L10n.logFormVisitTitle, text: $draft.title)

                TextField(L10n.logFormVisitContent, text: $draft.content, axis: .vertical)
                    .lineLimit(4...8)

                Button(L10n.logFormAttachPhoto) {
                    onAttachPhoto()
                }

                if let photo = draft.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
