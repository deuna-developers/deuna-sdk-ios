import Foundation

/// Defines how the selected widget is presented in the sample app.
enum ExplorePresentationMode: String, CaseIterable, Identifiable, Codable {
    case embedded
    case modal
    case autoResize

    var id: String { rawValue }

    var title: String {
        switch self {
        case .embedded: return "Embedded"
        case .modal: return "Modal"
        case .autoResize: return "Auto Resize"
        }
    }
}
