import Foundation

struct EmojisFileGroup: Codable {
    let name: String
    let slug: String
    let emojis: [EmojisFileEmoji]
}

