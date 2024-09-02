//
//  SuccessView.swift
//  basic-integration
//
//  Created by Darwin Morocho on 8/3/24.
//

import Foundation
import SwiftUI

public struct VaultSuccessView: View{
    public let savedCardData: [String: Any]
    public let onBack: () -> Void
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Card saving successful")
            Text("ID: \(savedCardData["id"]!)")
            Text("Company: \(savedCardData["company"]!)")
            Text("Expiration Date: \(savedCardData["expirationDate"]!)")
            Text("Last 4 digits: \(savedCardData["lastFour"]!)")
            Button(
                action: onBack
            ){
                Text("Go back").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
            
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
    VaultSuccessView(
        savedCardData: getMock()!,
        onBack: {}
    )
}
