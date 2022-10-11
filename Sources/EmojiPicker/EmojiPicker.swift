import SwiftUI
import Introspect

public struct EmojiPicker: View {
    
    @StateObject var viewModel: ViewModel

    @State var hasBecomeFirstResponder: Bool = false

    let didTapEmoji: ((String) -> Void)
    let focusOnAppear: Bool
    
    public init(
        categories: [EmojiCategory]? = nil,
        focusOnAppear: Bool = false,
        didTapEmoji: @escaping ((String) -> Void)
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(categories: categories))
        self.didTapEmoji = didTapEmoji
        self.focusOnAppear = focusOnAppear
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                grid
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Select an Emoji")
            .introspectTextField(customize: introspectTextField)
        }
    }
    
    /// We're using this to focus the textfield seemingly before this view even appears (as the `.onAppear` modifier—shows the keyboard coming up with an animation
    func introspectTextField(_ uiTextField: UITextField) {
        guard focusOnAppear, !hasBecomeFirstResponder else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiTextField.becomeFirstResponder()
            /// Set this so further invocations of the `introspectTextField` modifier doesn't set focus again (this happens during dismissal for example)
            hasBecomeFirstResponder = true
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
        EmojiPicker(focusOnAppear: true) { emoji in
            
        }
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerPreview()
    }
}
