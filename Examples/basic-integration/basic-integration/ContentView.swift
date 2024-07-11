import Combine
import DeunaSDK
import SwiftUI
import WebKit

enum SuccessType: String {
    case payment = "Payment successful"
    case saveCard = "Save Card successful"
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var success: SuccessType? = nil
    @State var order: [String: Any]? = nil
    @State var error: Error? = nil

    var body: some View {
        if success != nil {
            if success == .saveCard {
                VaultSuccessView {
                    onBack: do {
                        success = nil
                    }
                }
            } else if order != nil {
                PaymentSuccessView(
                    order: order!,
                    onBack: {
                        success = nil
                        order = nil
                    }
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
                                    success = .payment
                                    order = data["order"] as? [String: Any]

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
                                    success = .payment
                                    order = data["order"] as? [String: Any]

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
                                case .success:
                                    success = .saveCard

                                case .canceled:
                                    print("Canceled by user")

                                case .error(let error):
                                    print("Error \(error.type)")
                                }
                            }
                        }
                    ) {
                        Text("Save Card").frame(maxWidth: .infinity)
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
