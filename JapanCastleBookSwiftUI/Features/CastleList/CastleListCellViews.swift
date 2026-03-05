import JapanCastleBook
import SwiftUI

struct CastleListCellRowView: View {
    @EnvironmentObject private var experienceStore: CastleExperienceStore

    let castles: [Castle]
    let onTapCastle: (Castle) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(castles, id: \.id) { castle in
                Button {
                    onTapCastle(castle)
                } label: {
                    CastleListCellView(
                        castle: castle,
                        hasVisited: experienceStore.hasVisited(castle.id)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }

            if castles.count < 3 {
                ForEach(0..<(3 - castles.count), id: \.self) { _ in
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct CastleListCellView: View {
    @Environment(\.castleStampAssetService) private var stampAssetService

    let castle: Castle
    let hasVisited: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.tertiarySystemFill), lineWidth: 2)
                    )

                Image(AssetImage.castle)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.25)
                    .padding(14)

                if hasVisited {
                    Image(stampAssetService.stampAssetName(for: castle.id) ?? AssetImage.doneStamp)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .transition(.opacity)
                }
            }
            .frame(height: 84)

            Text("\(castle.id). \(castle.name)")
                .font(castle.name.count > 10 ? .caption2 : .caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 2)
    }
}
