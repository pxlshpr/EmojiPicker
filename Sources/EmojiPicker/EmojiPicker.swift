import SwiftUI
import SwiftUISugar
import SwiftHaptics

public struct EmojiPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var model: Model
    @State var searchIsFocused = false

    let didTapEmoji: ((String) -> Void)
    let focusOnAppear: Bool
    let includeCancelButton: Bool
    let includeClearButton: Bool
    let size: EmojiSize
    @Binding var recents: [String]

    public enum EmojiSize {
        case large
        case small
        
        var fontSize: CGFloat {
            switch self {
            case .large: return 50
            case .small: return 30
            }
        }

        var columnSize: CGFloat {
            fontSize + spacing
        }

        var spacing: CGFloat {
            switch self {
            case .large: return 20
            case .small: return 5
            }
        }
        
        var sectionSpacing: CGFloat {
            switch self {
            case .large: return 0
            case .small: return 20
            }
        }
    }
    
    public init(
        recents: Binding<[String]> = .constant([]),
        size: EmojiSize = .large,
        categories: [EmojiCategory]? = nil,
        focusOnAppear: Bool = false,
        includeCancelButton: Bool = false,
        includeClearButton: Bool = false,
        didTapEmoji: @escaping ((String) -> Void)
    ) {
        let model = Model(categories: categories, recents: recents.wrappedValue)
        _model = StateObject(wrappedValue: model)
        _recents = recents
        self.size = size
        self.didTapEmoji = didTapEmoji
        self.focusOnAppear = focusOnAppear
        self.includeClearButton = includeClearButton
        self.includeCancelButton = includeCancelButton
    }
    
    public var body: some View {
        NavigationView {
            SearchableView(
                searchText: $model.searchText,
                promptSuffix: "Emojis",
                focused: $searchIsFocused,
//                focusOnAppear: focusOnAppear,
                didSubmit: didSubmit,
                content: {
                    scrollView
                })
            .navigationTitle("Select an Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
//                if focusOnAppear {
//                    searchIsFocused = true
//                }
            }
            .toolbar { leadingContents }
            .toolbar { trailingContents }
//            .interactiveDismissDisabled(includeCancelButton)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: recents) { newValue in
                model.initialRecents = newValue
                model.updateData()
            }
        }
    }
    
    var trailingContents: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if includeCancelButton {
                Button {
                    Haptics.feedback(style: .soft)
                    dismiss()
                } label: {
                    CloseButtonLabel()
                }
            }
        }
    }
    
    var leadingContents: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if includeClearButton {
                Button {
                    Haptics.feedback(style: .soft)
                    didTapEmoji("")
                } label: {
                    Text("Clear")
                }
            }
        }
    }
    
    func didSubmit() {
        
    }
    
    var scrollView: some View {
        ScrollView {
            if !model.recents.isEmpty {
                recentsGrid
            }
            grid
        }
    }
    
    var grid: some View {
        
        func isFirst(_ index: Int) -> Bool {
            guard model.recents.isEmpty else { return false }
            return model.gridData.firstIndex(where: { !$0.emojis.isEmpty }) == index
        }

        var columns: [GridItem] {
            [GridItem(.adaptive(minimum: size.columnSize))]
        }

        return LazyVGrid(columns: columns, spacing: size.spacing) {
            ForEach(model.gridData.indices, id: \.self) { i in
                if !model.gridData[i].emojis.isEmpty {
                    section(for: model.gridData[i], isFirst: isFirst(i))
                }
            }
        }
        .padding(.horizontal)
    }

    var recentsGrid: some View {

        var header: some View {
            Text("Recents")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        var columns: [GridItem] {
            [GridItem(.adaptive(minimum: 50))]
        }

        return LazyVGrid(columns: columns, spacing: 10) {
            Section(header: header) {
                ForEach(model.recents, id: \.self) { emoji in
                    button(for: emoji, fontSize: 50)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func section(for gridSection: Model.GridSection, isFirst: Bool = false) -> some View {
        
        
        @ViewBuilder
        var header: some View {
            if model.gridData.count > 1 {
                Text(gridSection.category)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(!isFirst, transform: { view in
                        view
                            .padding(.top, size.sectionSpacing)
                    })
            } else {
                EmptyView()
            }
        }
        
        return Section(header: header) {
            ForEach(gridSection.emojis, id: \.self) { emoji in
                button(for: emoji.emoji)
            }
        }
    }
    
    func button(for emoji: String, fontSize: CGFloat? = nil) -> some View {
        Text(emoji)
            .font(.system(size: fontSize ?? size.fontSize))
            .onTapGesture {
                didTapEmoji(emoji)
            }
    }
}

public struct EmojiPickerPreview: View {
    
    @Environment(\.dismiss) var dismiss
    
    public init() { }
    
    public var body: some View {
        EmojiPicker(
            recents: .constant(["😎", "🎸", "🫠", "🤯"]),
            size: .small,
            focusOnAppear: true,
            includeCancelButton: true
        ) { emoji in
            dismiss()
        }
    }
}

struct EmojiPicker_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerPreview()
    }
}
