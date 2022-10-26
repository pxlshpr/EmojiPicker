import SwiftUI
import SwiftUISugar

public struct EmojiPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @State var searchIsFocused = false

    let didTapEmoji: ((String) -> Void)
    let focusOnAppear: Bool
    let includeCancelButton: Bool

    public init(
        categories: [EmojiCategory]? = nil,
        focusOnAppear: Bool = false,
        includeCancelButton: Bool = false,
        didTapEmoji: @escaping ((String) -> Void)
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(categories: categories))
        self.didTapEmoji = didTapEmoji
        self.focusOnAppear = focusOnAppear
        self.includeCancelButton = includeCancelButton
    }
    
    public var body: some View {
        NavigationView {
            SearchableView(
                searchText: $viewModel.searchText,
                prompt: "Search Emojis",
                focused: $searchIsFocused,
                didSubmit: didSubmit,
                content: {
                    scrollView
                })
            .navigationTitle("Select an Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if focusOnAppear {
                    searchIsFocused = true
                }
            }
            .toolbar { navigationLeadingItem }
            .interactiveDismissDisabled(includeCancelButton)
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    var navigationLeadingItem: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if includeCancelButton {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    func didSubmit() {
        
    }
    
    var scrollView: some View {
        ScrollView {
            grid
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
            didTapEmoji(emoji)
        } label: {
            Text(emoji)
                .font(.system(size: 50))
        }
    }
}

public struct EmojiPickerPreview: View {
    
    public init() { }
    
    public var body: some View {
        EmojiPicker(focusOnAppear: true, includeCancelButton: true) { emoji in
            
        }
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerPreview()
    }
}
