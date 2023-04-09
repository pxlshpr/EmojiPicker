import SwiftUI

class Model: ObservableObject {
    
    typealias GridSection = (category: String, emojis: [EmojiWithCategory])
    typealias GridData = [GridSection]

    @Published public var searchText = "" {
        didSet {
            updateGridData()
        }
    }
    @Published public var categories: [EmojiCategory]?
    @Published public var gridData: GridData = []

    private var emojis: Emojis = Emojis(categories: [])

    public init(categories: [EmojiCategory]?) {
        self.categories = categories
        loadEmojisFromFile()
    }
    
    public func loadEmojisFromFile() {
        Task {
            guard let path = Bundle.module.path(forResource: "emojis", ofType: "json") else {
                return
            }
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.emojis = try JSONDecoder().decode(Emojis.self, from: data)
                await MainActor.run {
                    updateGridData()
                }
            } catch {
                print(error)
            }
        }
    }

    public func updateGridData() {
        let categories = categories ?? EmojiCategory.allCases
        gridData = emojis.gridData(for: categories, searchText: searchText)
    }
}

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
