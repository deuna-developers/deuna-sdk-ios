import Foundation
public typealias Json = [String:Any]


extension Json {
    func encode() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            DeunaLogs.error(error.localizedDescription)
            return nil
        }
    }
}
