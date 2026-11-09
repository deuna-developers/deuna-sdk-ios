import Foundation

struct ApmOption: Identifiable {
    var id: String { label }
    let label: String
    let paymentMethods: [[String: Any]]
    let logo: String
    let iosCompatible: Bool
    let androidCompatible: Bool
}
