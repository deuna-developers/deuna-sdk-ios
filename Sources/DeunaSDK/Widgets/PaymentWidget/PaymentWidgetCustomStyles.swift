
/**
 * Custom styles that can be passed to the payment widget
 * using the setCustomStyles function.
 */
class PaymentWidgetCustomStyles: Codable {

    var hidePoweredBy: Bool?
    var saveButton: SaveButton?
    var upperTag: Tag?
    var lowerTag: Tag?

    // Structure for the custom save button
    struct SaveButton: Codable {
        let content: String // Custom button text
        let style: SaveButtonStyle? // Custom button style

        // Structure for the save button style
        struct SaveButtonStyle: Codable {
            let color: String // Hex button text color
            let backgroundColor: String // Hex background button color
        }
    }

    // Class for the tag
    class Tag: Codable {
        var title: Title? // Tag title

        // Structure for the title
        struct Title: Codable {
            let content: String? // Title content
        }
    }
}
