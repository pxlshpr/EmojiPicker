import Foundation

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
