import SwiftUI

struct SegmentedPillSelector<Item: Identifiable>: View {
    let items: [Item]
    let selectedId: Item.ID
    let titleProvider: (Item) -> String
    let onSelect: (Item) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    Text(titleProvider(item))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(
                            selectedId == item.id ? ExploreColors.brandBlue : ExploreColors.labelGray
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedId == item.id ? Color.white : Color.clear)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ExploreColors.cardBackground)
        .cornerRadius(16)
    }
}
