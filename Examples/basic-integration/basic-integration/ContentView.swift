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

    var body: some View {
        if success != nil {
            SuccessView(
                message: success!.rawValue,
                onBack: {
                    success = nil
                }
            )
        } else {
            VStack(spacing: 16) {
                VStack {
                    TextField("Order Token", text: $viewModel.orderToken).textFieldStyle(.roundedBorder)
                    TextField("User Token", text: $viewModel.userToken).textFieldStyle(.roundedBorder)
                }.padding(.bottom, 20)

                VStack(spacing: 16) {
                    Button(
                        action: {
                            viewModel.processPayment { result in
                                // Handle payment completion or error
                                switch result {
                                case .success(let response):
                                    success = .payment
                                case .canceled:
                                    print("Canceled by user")
                                    
                                case .error(let error):
                                    print("Error \(error.type)")
                                }
                            }
                        }
                    ) {
                        Text("Process Payment").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)

                    Button(
                        action: {
                            viewModel.saveCard { result in
                                // Handle saving card completion or error
                                switch result {
                                case .success(let response):
                                    success = .payment
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
            .padding()
        }
    }
}

#Preview {
    ContentView(
        viewModel: ViewModel(
            deunaSDK: DeunaSDK(environment: .sandbox, publicApiKey: "")
        )
    )
}
