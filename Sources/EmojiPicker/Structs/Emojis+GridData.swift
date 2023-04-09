import Foundation

extension Emojis {
    func gridData(for filteredCategories: [EmojiCategory], searchText: String) -> Model.GridData {
        var gridData = Model.GridData()
        for filteredCategory in filteredCategories {
            guard let category = categories.first(where: { $0.name == filteredCategory.rawValue }),
                  !category.emojis.isEmpty else {
                continue
            }
            
            let emojis: [Emoji]
            if searchText.isEmpty {
                emojis = category.emojis
            } else {
                emojis = category.emojis.filter({
                    //TODO: use regex to match start of words only and do other heuristics
                    $0.name.contains(searchText.lowercased())
                    ||
                    $0.keywords.contains(searchText.lowercased())
                })
            }
            
            gridData.append(Model.GridSection(
                category: filteredCategory.description,
                emojis: emojis.map {
                    EmojiWithCategory(
                        category: filteredCategory,
                        emoji: $0.emoji
                    )
                }
            ))
        }
        return gridData
    }
}
