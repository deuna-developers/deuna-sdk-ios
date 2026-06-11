import Foundation

struct ApmOption: Identifiable {
    var id: String { processor }
    let paymentMethod: String
    let processor: String
    let logo: String
    let iosCompatible: Bool
    let androidCompatible: Bool
}
