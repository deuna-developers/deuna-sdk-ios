import Foundation
extension Dictionary where Key == String, Value == Any {
    func toFormattedJsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error al serializar el diccionario a JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
