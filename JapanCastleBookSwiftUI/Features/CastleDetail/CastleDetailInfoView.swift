import JapanCastleBook
import SwiftUI

struct CastleDetailInfoView: View {
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

    private var imageURLs: [URL] { castle.imageURLs }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if imageURLs.isEmpty {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .overlay {
                                    Text(L10n.detailNoImageProvided)
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 4)
                        } else {
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
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                        }
                    }
                    .frame(height: 230)

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
