import Foundation

struct Emojis: Codable {
    let categories: [Category]
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
