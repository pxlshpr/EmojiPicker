import SwiftUI

class ViewModel: ObservableObject {
    
    typealias GridSection = (category: String, emojis: [String])
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
