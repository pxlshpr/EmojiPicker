import SwiftUI

class Model: ObservableObject {
    
    typealias GridSection = (category: String, emojis: [EmojiWithCategory])
    typealias GridData = [GridSection]

    @Published public var searchText = "" {
        didSet {
            updateData()
        }
    }
    @Published public var categories: [EmojiCategory]?
    @Published public var gridData: GridData = []

    @Published public var initialRecents: [String] = []
    @Published public var recents: [String] = []

    private var emojis: Emojis = Emojis(categories: [])

    public init(categories: [EmojiCategory]?, recents: [String]) {
        self.categories = categories
        self.initialRecents = recents
        self.recents = []
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
                    updateData()
                }
            } catch {
                print(error)
            }
        }
    }

    public func updateData() {
        let categories = categories ?? EmojiCategory.allCases
        gridData = emojis.gridData(for: categories, searchText: searchText)
        recents = emojis.recentStrings(for: initialRecents, searchText: searchText)
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
