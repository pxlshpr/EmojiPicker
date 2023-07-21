import Foundation

struct EmojisFileEmoji: Codable {
    let emoji: String
    let skin_tone_support: Bool
    let name: String
    let slug: String
    let unicode_version: String
    let emoji_version: String
}
