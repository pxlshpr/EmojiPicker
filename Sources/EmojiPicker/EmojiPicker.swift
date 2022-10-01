import SwiftUI

extension Emojis {
    func gridData(for filteredCategories: [EmojiCategory], searchText: String) -> ViewModel.GridData {
        var gridData = ViewModel.GridData()
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
                    //TODO: Include keyword searches here—use regex to match start of words only
                    $0.name.contains(searchText.lowercased())
                })
            }
            
            gridData.append(ViewModel.GridSection(
                category: filteredCategory.description,
                emojis: emojis.map { $0.emoji }
            ))
        }
        return gridData
    }
}

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

public struct EmojiPicker: View {
    
    @StateObject var viewModel: ViewModel
    
    init(categories: [EmojiCategory]? = nil) {
        _viewModel = StateObject(wrappedValue: ViewModel(categories: categories))
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                grid
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Select an Emoji")
        }
    }
    
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 70))]
    }
    
    var grid: some View {
        LazyVGrid(
            columns: columns,
            spacing: 20
        ) {
            ForEach(viewModel.gridData, id: \.self.category) { gridSection in
                if !gridSection.emojis.isEmpty {
                    section(for: gridSection)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func section(for gridSection: ViewModel.GridSection) -> some View {
        @ViewBuilder
        var header: some View {
            if viewModel.gridData.count > 1 {
                Text(gridSection.category)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                EmptyView()
            }
        }
        
        return Section(header: header) {
            ForEach(gridSection.emojis, id: \.self) { emoji in
                button(for: emoji)
            }
        }
    }
    
    func button(for emoji: String) -> some View {
        Button {
        } label: {
            Text(emoji)
                .font(.system(size: 50))
        }
    }
}

public struct EmojiPickerPreview: View {
    
    public init() { }
    
    public var body: some View {
        EmojiPicker()
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerPreview()
    }
}
