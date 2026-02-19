import DeunaSDK
import SwiftUI

enum NavigationDestination: Hashable {
    case paymentSuccess(orderJsonData: Data)
    case saveCardSuccess(cardJsonData: Data)
}

struct MainScreen: View {
    let deunaSDK: DeunaSDK

    @State var orderToken = ""
    @State var userToken = ""
    @State var fraudId = ""
    @State var widgetToShow: WidgetToShow = .paymentWidget
    
    @State var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath){
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                VStack {
                    
                    if !fraudId.isEmpty {
                        Text("Fraud Id: \(fraudId)")
                    }
                 
                    HStack {
                        WidgetPicker(selectedWidget: $widgetToShow)
                        DeunaButton(label: "Show") {
                            showWidget()
                        }
                        DeunaButton(label: "Fraud Id") {
                            generateFraudId()
                        }
                        
                    }.padding(.bottom, 10)
                    
                    TextInput(text: $orderToken, label: "Order Token")
                    TextInput(text: $userToken, label: "User Token")
                }.padding()
            }.navigationDestination(for: NavigationDestination.self){ destination in
                switch destination {
                case .paymentSuccess(let orderJsonData):
                    if let orderJson = try? JSONSerialization.jsonObject(with: orderJsonData) as? [String: Any] {
                        PaymentSuccessView(order: orderJson)
                    }
                    
                case .saveCardSuccess(let cardJsonData):
                    if let cardJson = try? JSONSerialization.jsonObject(with: cardJsonData) as? [String: Any] {
                        CardSavedSuccessView(savedCardData: cardJson)
                    }
                }
            }
        }
    }
}

#Preview {
    MainScreen(
        deunaSDK: DeunaSDK(
            environment: .sandbox,
            publicApiKey: "YOUR_PUBLIC_APIKEY"
        )
    )
}
