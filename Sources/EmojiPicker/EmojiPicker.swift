import SwiftUI

public class ViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var categories: [EmojiCategory]?
    @Published var emojis: Emojis = Emojis(categories: [])
    
    init(categories: [EmojiCategory]?) {
        self.categories = categories
    }
    
    func loadEmojisFromFile() {
        let start = CFAbsoluteTimeGetCurrent()
        guard let path = Bundle.module.path(forResource: "emojis", ofType: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let emojis = try JSONDecoder().decode(Emojis.self, from: data)
            print("It took us: \(CFAbsoluteTimeGetCurrent()-start)")
            return
        } catch {
            print(error)
            return
        }
    }
    
    var filteredEmojis: [String] {
        if searchText.isEmpty {
            return []
//            return foodAndDrink.map { $0.0 }
        } else {
            return []
//            return animalsAndNature.filter {
//                $0.1.contains(searchText.lowercased())
//            }
//            .map { $0.0 }
        }
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
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(viewModel.filteredEmojis, id: \.self) { emoji in
                Button {
                } label: {
                    Text(emoji)
                        .font(.system(size: 50))
                }
            }
        }
        .padding(.horizontal)
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
