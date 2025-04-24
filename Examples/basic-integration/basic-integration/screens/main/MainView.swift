//
//  MainView.swift
//  basic-integration
//
//  Created by deuna on 26/3/25.
//

import Combine
import DeunaSDK
import SwiftUI
import WebKit

enum ViewToShow {
    case success(SuccessType,Json)
    case form
    case embeddedPayment(WidgetToShow)
}

enum WidgetToShow: String, Codable{
    case paymentWidget
    case nextActionWidget
    case voucherWidget
    case checkoutWidget
    case vaultWidget
    case clickToPayWidget
    
    static var allCases: [WidgetToShow] {
        return [.paymentWidget,.nextActionWidget,.voucherWidget, .checkoutWidget, .vaultWidget, .clickToPayWidget]
    }
}

struct MainView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State var viewToShow: ViewToShow = .form
    @State private var error: Error? = nil
    
    func handlePaymentSuccess(order: Json) {
        viewToShow = .success(.payment,order)
    }

    func handleCardSavedSuccess(successType: SuccessType, data: Json) {
        if let savedCardData = (data["metadata"] as? Json)?["createdCard"] as? Json {
            viewToShow = .success(successType, savedCardData)
        }
    }

    func goBack() {
        viewToShow = .form
        error = nil
    }

    var body: some View {
        VStack {
            switch viewToShow {
            case .success(let successType, let json):
                switch successType {
                case .payment:
                    PaymentSuccessView(
                        order: json,
                        onBack: goBack
                    )
                case .saveCard:
                    CardSavedSuccessView(
                        title: "Card saved successfully",
                        savedCardData: json,
                        onBack: goBack
                    )
                case .clickToPay:
                    CardSavedSuccessView(
                        title: "Click To Pay enrollment successful",
                        savedCardData: json,
                        onBack: goBack
                    )
                }
            case .form:
                DeunaFormView(
                    viewModel: viewModel,
                    handlePaymentSuccess: handlePaymentSuccess,
                    handleCardSavedSuccess: handleCardSavedSuccess,
                    setError: { error in
                        if error != self.error {
                            self.error = error
                        }
                    },
                    onShowEmbeddedWidget: { type in
                        viewToShow = .embeddedPayment(type)
                    }
                )
            case .embeddedPayment(let widgetToShow):
                DeunaWidgetWrapper(
                    deunaSDK: viewModel.deunaSDK,
                    orderToken: viewModel.orderToken,
                    userToken: viewModel.userToken,
                    widgetToShow: widgetToShow,
                    onBack: goBack,
                    handlePaymentSuccess: handlePaymentSuccess,
                    handleCardSavedSuccess: handleCardSavedSuccess,
                    setError: { error in
                        if error != self.error {
                            self.error = error
                        }
                    }
                )
            }
        }.alert(item: $error) { error in
            Alert(
                title: Text(error.code),
                message: Text(error.message),
                dismissButton: .default(Text("OK"), action: {
                    // Asegura que esto no ocurra directamente durante el render
                    DispatchQueue.main.async {
                        self.error = nil
                    }
                })
            )
        }
    }
}



#Preview {
    struct DeunaWidgetPreviewWrapper: View {
        @StateObject private var viewModel: ViewModel
        
        init(viewModel: ViewModel = ViewModel(
            deunaSDK: Mocks.deunaSDK
        )) {
            _viewModel = StateObject(wrappedValue: viewModel)
            viewModel.orderToken = "5f136718-c2d0-4cad-be2f-88ef5a8d1407"
        }

        var body: some View {
            MainView(
                viewModel: viewModel
            )
        }
    }

    return DeunaWidgetPreviewWrapper()
}
