import SwiftUI
import UIKit

struct VisitLogFormView: View {
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
