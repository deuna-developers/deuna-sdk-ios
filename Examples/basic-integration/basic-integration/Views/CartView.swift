import SwiftUI

struct CartView: View {
    var body: some View {
        let imageUrl = URL(string: "https://camo.githubusercontent.com/50fa432906fc45b20062b150933db8f0bb86682ec6540624a19a72c59eb20d81/68747470733a2f2f642d756e612d6f6e652e73332e75732d656173742d322e616d617a6f6e6177732e636f6d2f67657374696f6e61646f5f706f725f642d756e612e706e67")!

        URLImage(url: imageUrl)
            .frame(height: 50)  // Adjust height as needed
            .padding()
            .font(.largeTitle)
            .padding()
        
        VStack(alignment: .leading, spacing: 10) {
            ProductRow(productName: "Hoodie", quantity: "2", price: "€30.00")
            ProductRow(productName: "Hat", quantity: "1", price: "€20.00")
        }
        .padding()

        Divider()

        HStack {
            Text("Subtotal")
            Spacer()
            Text("USD 50.00")
        }
        .padding(.horizontal)

        HStack {
            Text("Shipping")
            Spacer()
            Text("Free")
        }
        .padding(.horizontal)

        Divider()

        HStack {
            Text("Total")
                .font(.headline)
            Spacer()
            Text("USD 50.00")
                .font(.headline)
        }
        .padding(.horizontal)
    }
}
