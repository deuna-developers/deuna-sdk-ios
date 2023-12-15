//
//  DeunaSDK+MessageHandler.swift
//
//

import Foundation
import WebKit



extension DeunaSDK: WKScriptMessageHandler{
    // MARK: - WKScriptMessageHandler Method
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let decoder = JSONDecoder()
        if let jsonString = message.body as? String {
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let eventData = try decoder.decode(CheckoutEventResponse.self, from: jsonData)
                    self.log("GOT EVENT: \(eventData.type)\n")
                    callbacks.eventListener?(eventData.type,eventData)
                    
                    
                    switch eventData.type {
                    case .purchase, .apmSuccess:
                        self.closeSubWebView()
                        self.ProcessingEnded("success")
                        if DeunaSDK.shared.closeOnSuccess == true{
                            self.closeCheckout()
                        }
                        callbacks.onSuccess?(eventData)
                        break
                    case .purchaseRejected, .purchaseError:
                        if let metadata = eventData.data.metadata {
                            let errorDeuna = DeUnaErrorMessage(message: metadata.errorMessage ?? "Default error message", type: .paymentError, order: eventData.data.order)
                            self.ProcessingEnded("error")
                            callbacks.onError?(errorDeuna)
                        }else{
                            self.ProcessingEnded("error")
                            callbacks.onError?(DeUnaErrorMessage(message:"unknown error", type: .unknownError))
                        }
                        self.closeSubWebView()
                        self.ProcessingEnded("error")
                        break
                    case .linkClose, .linkFailed:
                        callbacks.onClose?()
                        self.closeCheckout()
                        break
                    case .checkoutStarted, .paymentMethodsAddCard, .paymentMethodsCardExpirationDateInitiated , .paymentClick, .paymentMethodsCardNumberInitiated, .paymentMethodsCardNumberEntered, .paymentMethodsEntered, .paymentMethodsSelected, .paymentMethodsStarted, .adBlock, .linkStarted, .paymentMethodsCardNameEntered,.paymentMethodsCardSecurityCodeInitiated,.paymentMethodsCardSecurityCodeEntered, .paymentMethodsCardExpirationDateEntered, .paymentMethodsCardNameInitiated, .paymentMethodsNotAvailable,
                        .vaultStarted,
                        .vaultSaveClick,
                        .paymentMethodsShowMyCards,
                        .benefitsStarted,
                        .vaultProcessing,
                        .vaultRedirect3DS,
                        .paymentMethodsShowMore,
                        .changeAddress,
                        .pointsToWinStarted:
                        break
                    case .paymentProcessing:
                        self.ProcessingStarted()
                        break
                    case .vaultSaveError, .vaultFailed:
                        let eventDataElement = try decoder.decode(ElementEventResponse.self, from: jsonData)
                        elementsCallbacks.eventListener?(eventData.type,eventDataElement)
                        if let metadata = eventDataElement.data.metadata {
                            let errorDeuna = DeUnaErrorMessage(message: metadata.errorMessage ?? "Default error message", type: .paymentError, user: eventDataElement.data.user)
                            elementsCallbacks.onError?(errorDeuna)
                        }else{
                            elementsCallbacks.onError?(DeUnaErrorMessage(message:"uknown error", type: .unknownError))
                        }
                        self.closeSubWebView()
                        self.ProcessingEnded("vault error")
                        break
                    case .vaultSaveSuccess:
                        let eventDataElement = try decoder.decode(ElementEventResponse.self, from: jsonData)
                        elementsCallbacks.eventListener?(eventData.type,eventDataElement)
                        self.closeSubWebView()
                        if DeunaSDK.shared.closeOnSuccess == true{
                            self.closeCheckout()
                        }
                        self.ProcessingEnded("vault success")
                        elementsCallbacks.onSuccess?(eventDataElement)
                        break
                    case .vaultClosed:
                        let eventDataElement = try decoder.decode(ElementEventResponse.self, from: jsonData)
                        elementsCallbacks.eventListener?(eventData.type,eventDataElement)
                        self.ProcessingEnded("vault closed")
                        self.closeSubWebView()
                        self.closeCheckout()
                        elementsCallbacks.onClose?()
                        break
                    case .paymentMethods3dsInitiated:
                        self.ProcessingStarted()
                        self.threeDsAuth=true
                        break
                    case .apmClickRedirect:
                        break
                    default:
                        self.log("Received unknown event type: \(eventData.type)")
                    }
                   
                    
                    if self.closeOnEvents.contains(eventData.type ){
                        self.ProcessingEnded("closing with event \(eventData.type)")
                        self.closeSubWebView()
                        self.closeCheckout()
                    }
                    
                    //Revisar eventos apmClickRedirect, linkFailed
                } catch {
                    print(error)
                    self.log(error.localizedDescription)
                    print(message.body)
                    let errorDeuna = DeUnaErrorMessage.init(message: error.localizedDescription, type: .unknownError)
                    if(callbacks.onError != nil){
                        callbacks.onError!(errorDeuna)
                    }
                    if(elementsCallbacks.onError != nil){
                        elementsCallbacks.onError!(errorDeuna)
                    }
                    
                }
            }
        }
    }
}
