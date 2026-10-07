import JapanCastleBook
import SwiftUI
import UIKit

struct CastleDetailLogView: View {
    private struct PhotoViewerPayload: Identifiable {
        let id = UUID()
        let photos: [UIImage]
        let initialIndex: Int
    }

    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castle: Castle
    let didTapEditLog: (CastleVisitLogEntry) -> Void
    let didTapDeleteLog: (CastleVisitLogEntry) -> Void
    @State private var activePhotoViewer: PhotoViewerPayload?

    private var logs: [CastleVisitLogEntry] {
        experienceStore.visitLogs(for: castle.id)
    }

    var body: some View {
        List {
            if logs.isEmpty {
                emptyLogsCard
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(logs) { log in
                    VisitLogPreviewCard(log: log) { photoIndex in
                        activePhotoViewer = PhotoViewerPayload(
                            photos: log.photos,
                            initialIndex: photoIndex
                        )
                    }
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
        .fullScreenCover(item: $activePhotoViewer) { payload in
            CastlePhotoViewer(photos: payload.photos, initialIndex: payload.initialIndex)
        }
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
    let onTapPhoto: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(log.date.formatted(date: .long, time: .omitted))
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
                            Button {
                                onTapPhoto(index)
                            } label: {
                                Image(uiImage: log.photos[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 132, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
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

private struct CastlePhotoViewer: View {
    @Environment(\.dismiss) private var dismiss

    let photos: [UIImage]
    let initialIndex: Int
    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.black.opacity(0.55))
                    .clipShape(Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 16)
        }
        .onAppear {
            currentIndex = min(max(0, initialIndex), max(photos.count - 1, 0))
        }
        .statusBarHidden(true)
    }
}
