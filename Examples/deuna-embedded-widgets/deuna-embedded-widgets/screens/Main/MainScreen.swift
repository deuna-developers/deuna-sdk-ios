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
    @State var config: DeunaWidgetConfiguration?
    @State var widgetToShow: WidgetToShow = .paymentWidget
    
    @State var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath){
            ZStack {
                Color.gray.opacity(0.2).ignoresSafeArea()
                
                VStack {
                    WidgetContainer(deunaSDK: deunaSDK, config: $config)
                    
                    HStack {
                        WidgetPicker(selectedWidget: $widgetToShow)
                        
                        if config != nil {
                            DeunaButton(label: "Pay") {
                                deunaSDK.submit{ _ in }
                            }
                            DeunaButton(
                                label: "Reset",
                                color: Color.orange
                            ) {
                                config = nil
                                deunaSDK.dispose()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    setConfig()
                                }
                            }
                        } else {
                            DeunaButton(label: "Show Widget") {
                                setConfig()
                            }
                        }
                        
                    }.padding()
                    
                    TextInput(text: $orderToken, label: "Order Token")
                    TextInput(text: $userToken, label: "User Token")
                }
                .padding()
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
