import Combine
import DeunaSDK
import SwiftUI
import WebKit

enum SuccessType: String {
    case payment = "Payment successful"
    case saveCard = "Save Card successful"
    case clickToPay = "Click To Pay successful"
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var success: SuccessType? = nil
    @State var order: [String: Any]? = nil
    @State var savedCardData: [String: Any]? = nil
    @State var error: Error? = nil

    func handlePaymentSuccess(data: Json) {
        success = .payment
        self.order = data["order"] as? Json
    }
    
    func handleCardSavedSuccess(successType: SuccessType, data:Json) {
        success = successType
        self.savedCardData = (data["metadata"] as? Json)?["createdCard"] as? Json
    }
    
    func goBack(){
        savedCardData = nil
        order = nil
        success = nil
    }

    var body: some View {
        if success != nil {
            if success == .clickToPay {
                CardSavedSuccessView(
                    title: "Click To Pay enrollment successful",
                    savedCardData: savedCardData!,
                    onBack: goBack
                )
            } else if success == .saveCard, let savedCardData = savedCardData {
                CardSavedSuccessView(
                    title: "Card saved successfully",
                    savedCardData: savedCardData,
                    onBack: goBack
                )
            } else if let order = order {
                PaymentSuccessView(
                    order: order,
                    onBack: goBack
                )
            }
        } else {
            VStack(spacing: 16) {
                VStack {
                    TextField("Order Token", text: $viewModel.orderToken).textFieldStyle(.roundedBorder)
                    TextField("User Token", text: $viewModel.userToken).textFieldStyle(.roundedBorder)
                }.padding(.bottom, 20)

                VStack(spacing: 16) {
                    Button(
                        action: {
                            viewModel.initPaymentWidget { result in
                                // Handle payment completion or error
                                switch result {
                                case .success(let data):
                                    handlePaymentSuccess(data: data)

                                case .canceled:
                                    print("Canceled by user")

                                case .error(let paymentWidgetError):
                                    error = Error(
                                        code: paymentWidgetError.metadata?.code ?? "",
                                        message: paymentWidgetError.metadata?.message ?? ""
                                    )
                                }
                            }
                        }
                    ) {
                        Text("Show Payment Widget").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)

                    Button(
                        action: {
                            viewModel.initCheckout { result in
                                // Handle payment completion or error
                                switch result {
                                case .success(let data):
                                    handlePaymentSuccess(data: data)

                                case .canceled:
                                    print("Canceled by user")

                                case .error(let checkoutError):
                                    error = Error(
                                        code: checkoutError.metadata?.code ?? "",
                                        message: checkoutError.metadata?.message ?? ""
                                    )
                                }
                            }
                        }
                    ) {
                        Text("show Checkout").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)

                    Button(
                        action: {
                            viewModel.saveCard { result in
                                // Handle saving card completion or error
                                switch result {
                                case .success(let data):
                                    handleCardSavedSuccess(successType: .saveCard, data: data)

                                case .canceled:
                                    print("Canceled by user")

                                case .error(let error):
                                    self.error = Error(
                                        code: error.metadata?.code ?? "",
                                        message: error.metadata?.message ?? ""
                                    )
                                }
                            }
                        }
                    ) {
                        Text("Save Card").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)

                    Button(
                        action: {
                            viewModel.clickToPay { result in
                                // Handle saving card completion or error
                                switch result {
                                case .success(let data):
                                    handleCardSavedSuccess(successType: .clickToPay, data: data)

                                case .canceled:
                                    print("Canceled by user")

                                case .error(let error):
                                    self.error = Error(
                                        code: error.metadata?.code ?? "",
                                        message: error.metadata?.message ?? ""
                                    )
                                }
                            }
                        }
                    ) {
                        Text("Click To Pay").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                }
            }
            .padding().alert(item: $error) { error in
                Alert(
                    title: Text(error.code),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ContentView(
        viewModel: ViewModel(
            deunaSDK: DeunaSDK(
                environment: .sandbox,
                publicApiKey: "fake_public_api_key"
            )
        ),
        error: Error(code: "FAKE", message: "Fake Error")
    )
}
