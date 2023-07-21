import Foundation

struct EmojiWithCategory: Identifiable, Hashable, Equatable {
    let category: EmojiCategory?
    let emoji: String
    
    init(category: EmojiCategory? = nil, emoji: String) {
        self.category = category
        self.emoji = emoji
    }
    
    var id: String {
        "\(category?.description ?? "recents")-\(emoji)"
    }
}
