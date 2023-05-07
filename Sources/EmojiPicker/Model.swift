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

    private var emojiGroups: [EmojisFileGroup] = []
    
    private var keywords: [String: [String]] = [:]

    public init(categories: [EmojiCategory]?, recents: [String]) {
        self.categories = categories
        self.initialRecents = recents
        self.recents = []
        loadEmojisFromFile()
    }

    public func loadEmojisFromFile() {
        Task {
            do {
                
                guard let emojisPath = Bundle.module.path(
                    forResource: "emojis-by-group",
                    ofType: "json")
                else { return }
                
                let emojisData = try Data(
                    contentsOf: URL(fileURLWithPath: emojisPath),
                    options: .mappedIfSafe
                )
                self.emojiGroups = try JSONDecoder().decode(
                    [EmojisFileGroup].self,
                    from: emojisData
                )

                guard let keywordsPath = Bundle.module.path(
                    forResource: "emoji-keywords",
                    ofType: "json")
                else { return }
                
                let keywordsData = try Data(
                    contentsOf: URL(fileURLWithPath: keywordsPath),
                    options: .mappedIfSafe
                )
                self.keywords = try JSONDecoder().decode(
                    [String : [String]].self,
                    from: keywordsData
                )
                
                await MainActor.run {
                    updateData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    public func loadEmojisFromFile_legacy() {
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

        gridData = emojiGroups.gridData(
            for: categories,
            searchText: searchText,
            allKeywords: keywords
        )
        recents = emojiGroups.recentStrings(
            for: initialRecents,
            searchText: searchText,
            allKeywords: keywords
        )
        
//        gridData = emojis.gridData(for: categories, searchText: searchText)
//        recents = emojis.recentStrings(for: initialRecents, searchText: searchText)
        
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
