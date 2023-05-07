import Foundation

struct EmojisFileGroup: Codable {
    let name: String
    let slug: String
    let emojis: [EmojisFileEmoji]
}

struct EmojisFileEmoji: Codable {
    let emoji: String
    let skin_tone_support: Bool
    let name: String
    let slug: String
    let unicode_version: String
    let emoji_version: String
}

//MARK: - Legacy

struct Emojis: Codable {
    let categories: [Category]
    
    func emoji(matching string: String) -> Emoji? {
        for category in categories {
            for emoji in category.emojis {
                if emoji.emoji == string {
                    return emoji
                }
            }
        }
        return nil
    }
}

struct Category: Codable {
    let name: String
    let emojis: [Emoji]
}

struct Emoji: Codable {
    let emoji: String
    let name: String
    let keywords: String
}
