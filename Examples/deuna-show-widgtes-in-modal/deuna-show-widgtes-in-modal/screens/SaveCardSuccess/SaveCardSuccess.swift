import Foundation
import SwiftUI

public struct CardSavedSuccessView: View{
    
    public let savedCardData: [String: Any]
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Card saved successfully")
            Text("ID: \(savedCardData["id"]!)")
            Text("Card brand: \(savedCardData["company"]!)")
            Text("Expiration Date: \(savedCardData["expiration_date"] ?? savedCardData["expirationDate"] ?? "")")
            Text("Last 4 digits: \(savedCardData["last_four"] ?? savedCardData["lastFour"] ?? "")")
        }.padding()
    }
    
}

private func getMock() -> [String: Any]? {
    let jsonString = """
      {
      "id": "4fd0584b-d336-4406-ad63-cc253fd47f14",
      "verifiedAt": "0001-01-01T00:00:00Z",
      "verifiedWithTransactionId": "",
      "firstSix": "424242",
      "verifiedBy": "",
      "bankName": "",
      "storedCard": false,
      "company": "visa",
      "expirationDate": "12/30",
      "cardHolder": "Test User",
      "userId": "45aa4524-1e98-4f5d-8845-20394f0f37ee",
      "cardType": "credit_card",
      "isValid": false,
      "cardId": "4fd0584b-d336-4406-ad63-cc253fd47f14",
      "lastFour": "4242",
      "createdAt": "2024-07-10T17:54:26.970636182Z",
      "cardHolderDni": "",
      "deletedAt": null
      }
    """
    
    do {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return json
    } catch {
        print("\(error.localizedDescription)")
        return nil
    }
}


#Preview {
    CardSavedSuccessView(
        savedCardData: getMock()!
    )
}
