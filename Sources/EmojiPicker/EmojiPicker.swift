import SwiftUI
import OSLog

import SwiftHaptics
import FormSugar
import ViewSugar

let emojiPickerLogger = Logger(subsystem: "EmojiPicker", category: "")

public struct EmojiPicker: View {
    
    @Environment(\.dismiss) var dismiss
    @State var searchIsFocused = false
    @State var model: EmojiPickerModel

    @State var searchIsActive: Bool = false
    @State var hasAppeared = false

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
        size: EmojiSize = .small,
        categories: [EmojiCategory]? = nil,
        focusOnAppear: Bool = false,
        includeCancelButton: Bool = false,
        includeClearButton: Bool = false,
        didTapEmoji: @escaping ((String) -> Void)
    ) {
        let model = EmojiPickerModel(categories: categories, recents: recents.wrappedValue)
        _model = State(initialValue: model)
        _recents = recents
        self.size = size
        self.didTapEmoji = didTapEmoji
        self.focusOnAppear = focusOnAppear
        self.includeClearButton = includeClearButton
        self.includeCancelButton = includeCancelButton
    }
    
    public var body: some View {
        Group {
            if hasAppeared {
                scrollView
                    .searchable(text: $model.searchText, isPresented: $searchIsActive, placement: .toolbar)
            } else {
                Color.clear
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.snappy) {
                                hasAppeared = true
                            }
                        }
                    }
            }
        }
        .navigationTitle("Choose Emoji")
        .toolbar { trailingContent }
        .toolbar { bottomContent }
        .onChange(of: recents) { oldValue, newValue in
            model.initialRecents = newValue
            model.updateData()
        }
    }
    
    var bottomContent: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                searchIsActive = true
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
    }
    
    var scrollView: some View {
        ScrollView {
            if !model.recents.isEmpty {
                recentsGrid
            }
            grid
        }
    }
    
    var trailingContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if includeClearButton {
                Button {
                    Haptics.selectionFeedback()
                    didTapEmoji("")
                    dismiss()
                } label: {
                    Text("Clear")
                }
            }
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
    
    func section(for gridSection: EmojiPickerModel.GridSection, isFirst: Bool = false) -> some View {
        
        
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
                dismiss()
            }
    }
}
