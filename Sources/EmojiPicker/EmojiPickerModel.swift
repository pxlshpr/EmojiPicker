import SwiftUI

@Observable class EmojiPickerModel {
    
    typealias GridSection = (category: String, emojis: [EmojiWithCategory])
    typealias GridData = [GridSection]

    var searchText = "" {
        didSet {
            updateData()
        }
    }
    var categories: [EmojiCategory]? = nil
    var gridData: GridData = []

    var initialRecents: [String] = []
    var recents: [String] = []

    var emojis: Emojis = Emojis(categories: [])

    var emojiGroups: [EmojisFileGroup] = []
    
    var keywords: [String: [String]] = [:]

    init(categories: [EmojiCategory]?, recents: [String]) {
        self.categories = categories
        self.initialRecents = recents
        self.recents = []
        loadEmojisFromFile()
    }

    func loadEmojisFromFile() {
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
                emojiPickerLogger.error("Error: \(error, privacy: .public)")
            }
        }
    }
    
    func updateData() {
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
    }
}
