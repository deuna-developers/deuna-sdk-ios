import SwiftUI
import WebKit
import Combine
import DeunaSDK

struct ContentView: View {
    @State private var selectedEnvironmentIndex: Int = Environment.development.rawValue
    @State private var apiKey: String = ""
    @State private var orderToken: String = ""
    @State private var userToken: String = ""
    @State private var showThankYouView = false
    @State private var showSavedCardSucccess = false
    @State private var isWebViewPresented = false

    var body: some View {
        ZStack {
            if !isWebViewPresented {
                
                VStack(alignment: .leading) {
                    CartView()
                    
                    OptionsView(selectedEnvironmentIndex: $selectedEnvironmentIndex,
                                apiKey: $apiKey,
                                orderToken: $orderToken,
                                userToken: $userToken,
                                onPayAction: processPayment,
                                onSavePaymentMethodAction: savePaymentMethod)
                    
                    if showThankYouView {
                        ThankYouView(showThankYouView: $showThankYouView)
                            .onDisappear {
                                isWebViewPresented = false // Esto se activará cuando la vista de agradecimiento desaparezca
                            }
                    }

                    if showSavedCardSucccess {
                        SavedCardSuccessView(showSavedCardSuccess: $showSavedCardSucccess)
                            .onDisappear {
                                isWebViewPresented = false // Esto se activará cuando la vista de éxito de tarjeta guardada desaparezca
                            }
                    }
                }.transition(.opacity)
            }
            
            if isWebViewPresented {
                EmptyView()
            }
        }
        .onAppear {
            withAnimation {
                self.isWebViewPresented = false
            }
        }
        .padding()
    }

    func processPayment() {
        let environment = Environment(rawValue: selectedEnvironmentIndex) ?? .development

        let callbacks = DeunaSDK.Callbacks()
        callbacks.onSuccess = { response in
            // Manejar caso de éxito
            print("Pago exitoso")
            DeunaSDK.shared.closeCheckout()
            self.showThankYouView = true
        }
        
        callbacks.onError = { error in
            // Manejar caso de error
            print("Error en el pago: \(error)")
            DeunaSDK.shared.closeCheckout()
            self.isWebViewPresented = false
        }
        
        callbacks.onClose = { webView in
            DispatchQueue.main.async {
                withAnimation {
                    print("Proceso de pago cerrado")
                    self.isWebViewPresented = false
                }
            }
        }
        
        callbacks.eventListener = { (type, data) in
            print("got event \(data)")
        }
        
        DeunaSDK.config(
            apiKey: apiKey,
            environment: environment, // or .production based on your need
            presentInModal: false, // Default: false , show the checkout in a pagesheet
            showCloseButton: true  // Default: true  ; Show a close button when
        )
        
        DeunaSDK.shared.initCheckout(callbacks: callbacks, orderToken: orderToken)
        isWebViewPresented = true
    }

    func savePaymentMethod() {
        let environment = Environment(rawValue: selectedEnvironmentIndex) ?? .development

        let callbacks = DeunaSDK.ElementsCallbacks()
        callbacks.onSuccess = { message in
            // Manejar caso de éxito
            print("Método de pago guardado exitosamente")
            self.showSavedCardSucccess = true

        }
        
        callbacks.onError = { error in
            // Manejar caso de error
            print("Error al guardar el método de pago: \(error)")
//            DeunaSDK.shared.closeElements()
        }
        
        callbacks.onClose = { webView in
            // Manejar acción de cierre
            print("Proceso de guardado de método de pago cerrado")
            isWebViewPresented = false
        }
        
        callbacks.eventListener = { (type, eventData) in
            print("Got event \(type)")
        }
        
        DeunaSDK.config(
            apiKey: apiKey,
            environment: environment, // or .production based on your need
            presentInModal: false, // Default: false , show the checkout in a pagesheet
            showCloseButton: true  // Default: true  ; Show a close button when
        )
        
        DeunaSDK.shared.initElements(element: .vault, callbacks: callbacks, userToken: userToken)
        isWebViewPresented = false
    }
}
