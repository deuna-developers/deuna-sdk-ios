import Combine
import DeunaSDK
import SwiftUI
import WebKit

enum SuccessType: String {
    case payment = "Payment successful"
    case saveCard = "Save Card successful"
    case clickToPay = "Click To Pay successful"
}

struct DeunaFormView: View {
    @ObservedObject var viewModel: ViewModel
    let handlePaymentSuccess: (Json) -> Void
    let handleCardSavedSuccess: (SuccessType, Json) -> Void
    let setError: (Error) -> Void
    let onShowEmbeddedWidget: (WidgetToShow) -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                TextField("Order Token", text: $viewModel.orderToken).textFieldStyle(.roundedBorder)
                TextField("User Token", text: $viewModel.userToken).textFieldStyle(.roundedBorder)
                
                Text("Fraud ID: \(viewModel.fraudId)").padding()
                Button(
                    action: viewModel.generateFraudId
                ) {
                    Text("Generate Fraud ID").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                
            }.padding(.bottom, 20)

            Picker("Experience", selection: $viewModel.widgetExperience) {
                ForEach(WidgetExperience.allCases) { experience in
                    Text(experience.label).tag(experience)
                }
            }
            .pickerStyle(.segmented)

            ForEach(WidgetToShow.allCases, id: \.self) { widget in
                Button(
                    action: {
                        switch viewModel.widgetExperience {
                            case .embedded:
                                onShowEmbeddedWidget(widget)
                            case .modal:
                            showWidgetInModal(widgetToShow: widget)
                        }
                    }
                ) {
                    Text(widget.rawValue).frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    struct DeunaFormPreviewWrapper: View {
        @State private var error: Error? = nil

        var body: some View {
            DeunaFormView(
                viewModel: ViewModel(
                    deunaSDK: Mocks.deunaSDK
                ),
                handlePaymentSuccess: { _ in },
                handleCardSavedSuccess: { _, _ in },
                setError: { error = $0 },
                onShowEmbeddedWidget: { _ in }
            )
        }
    }

    return DeunaFormPreviewWrapper()
}
