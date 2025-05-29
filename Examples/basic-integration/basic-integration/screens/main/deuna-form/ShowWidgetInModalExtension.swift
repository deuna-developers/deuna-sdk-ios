//
//  ShowWidgetInModalExtension.swift
//  basic-integration
//
//  Created by deuna on 2/4/25.
//

extension DeunaFormView {
    func showWidgetInModal(widgetToShow: WidgetToShow) {
        switch widgetToShow {
        case .paymentWidget:
            viewModel.initPaymentWidget { result in
                switch result {
                case .success(let order):
                    handlePaymentSuccess(order)
                case .canceled:
                    print("Canceled by user")
                case .error(let paymentError):
                    setError(Error(
                        code: paymentError.metadata?.code ?? "",
                        message: paymentError.metadata?.message ?? ""
                    ))
                }
            }
        case .nextActionWidget:
            viewModel.initNextAction { result in
                switch result {
                case .success(let order):
                    handlePaymentSuccess(order)
                case .canceled:
                    print("Canceled by user")
                case .error(let paymentError):
                    setError(Error(
                        code: paymentError.metadata?.code ?? "",
                        message: paymentError.metadata?.message ?? ""
                    ))
                }
            }
        case .voucherWidget:
            viewModel.initVoucher { result in
                switch result {
                case .success(let order):
                    handlePaymentSuccess(order)
                case .canceled:
                    print("Canceled by user")
                case .error(let paymentError):
                    setError(Error(
                        code: paymentError.metadata?.code ?? "",
                        message: paymentError.metadata?.message ?? ""
                    ))
                }
            }
        case .checkoutWidget:
            viewModel.initCheckout { result in
                switch result {
                case .success(let order):
                    handlePaymentSuccess(order)
                case .canceled:
                    print("Canceled by user")
                case .error(let paymentError):
                    setError(Error(
                        code: paymentError.metadata?.code ?? "",
                        message: paymentError.metadata?.message ?? ""
                    ))
                }
            }
        case .vaultWidget:
            viewModel.saveCard { result in
                switch result {
                case .success(let data):
                    handleCardSavedSuccess(.saveCard, data)
                case .canceled:
                    print("Canceled by user")
                case .error(let error):
                    setError(Error(
                        code: error.metadata?.code ?? "",
                        message: error.metadata?.message ?? ""
                    ))
                }
            }
        case .clickToPayWidget:
            viewModel.clickToPay { result in
                switch result {
                case .success(let data):
                    handleCardSavedSuccess(.clickToPay, data)
                case .canceled:
                    print("Canceled by user")
                case .error(let error):
                    setError(Error(
                        code: error.metadata?.code ?? "",
                        message: error.metadata?.message ?? ""
                    ))
                }
            }
        }
    }
}
