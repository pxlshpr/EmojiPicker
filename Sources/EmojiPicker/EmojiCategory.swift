import Foundation

public enum EmojiCategory: String, Equatable, CaseIterable {
    case smileysAndPeople
    case animalsAndNature
    case foodAndDrink
    case activity
    case travelAndPlaces
    case objects
    case symbols
    case flags
    
    var description: String {
        switch self {
        case .smileysAndPeople:
            return "Smileys & People"
        case .animalsAndNature:
            return "Animals & Nature"
        case .foodAndDrink:
            return "Food & Drink"
        case .activity:
            return "Activity"
        case .travelAndPlaces:
            return "Travel & Places"
        case .objects:
            return "Objects"
        case .symbols:
            return "Symbols"
        case .flags:
            return "Flags"
        }
    }
}
