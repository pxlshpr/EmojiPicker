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
    
    func recentStrings(for recents: [String], searchText: String) -> [String] {
        recents.compactMap {
            self.emoji(matching: $0)
        }
        .filter({
            guard !searchText.isEmpty else {
                return true
            }
            //TODO: use regex to match start of words only and do other heuristics
            return $0.name.contains(searchText.lowercased())
            ||
            $0.keywords.contains(searchText.lowercased())
        })
        .map { $0.emoji }
    }
}

extension Array where Element == EmojisFileGroup {
    
    func gridData(
        for filteredCategories: [EmojiCategory],
        searchText: String,
        allKeywords: [String : [String]]
    ) -> Model.GridData {
        
        var gridData = Model.GridData()
        for filteredCategory in filteredCategories {
            guard let category = self.first(where: {
                filteredCategory.emojisFileDescriptions.contains($0.name)
            }),
                  !category.emojis.isEmpty
            else {
                continue
            }
            
            let emojis: [EmojisFileEmoji]
            if searchText.isEmpty {
                emojis = category.emojis
            } else {
                
                let string = searchText.lowercased()
                //TODO: Do this
                emojis = category.emojis.filter({ emoji in
                    
                    let keywords = allKeywords[emoji.emoji] ?? []
                    
                    //TODO: use regex to match start of words only and do other heuristics
                    let bool = emoji.name.lowercased().contains(string)
                    ||
                    keywords.contains(where: { $0.contains(string) })
                    
                    if bool {
                        print("\(emoji.emoji): \(keywords.joined(separator: ";"))")
                    }
                    
                    return bool
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
    
    func emoji(_ string: String) -> EmojisFileEmoji? {
        for group in self {
            for emoji in group.emojis {
                if emoji.emoji == string {
                    return emoji
                }
            }
        }
        return nil
    }
    
    func recentStrings(
        for recents: [String],
        searchText: String,
        allKeywords: [String : [String]]
    ) -> [String] {
        recents.compactMap {
            self.emoji($0)
        }
        .filter({ emoji in
            guard !searchText.isEmpty else {
                return true
            }
            
            let string = searchText.lowercased()
            let keywords = allKeywords[emoji.emoji] ?? []
            
            //TODO: use regex to match start of words only and do other heuristics
            let bool = emoji.name.lowercased().contains(string)
            ||
            keywords.contains(where: { $0.contains(string) })
            
            if bool {
                print("\(emoji.emoji): \(keywords.joined(separator: ";"))")
            }

            return bool            
        })
        .map { $0.emoji }
    }
}
