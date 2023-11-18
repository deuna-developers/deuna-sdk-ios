// ContentView.swift
// DemoDeunaSdk
//
//

import SwiftUI
import DeunaSDK
import WebKit
import Combine


struct ContentView: View {
    @State private var showThankYouView = false
    @State private var inputToken: String = "-"
    @State private var apiKey: String = "-" //SET YOUR API KEY
    @State private var currentToken: String = "-" // SET THIS TOKE
    init(){
        DeunaSDK.shared.closeCheckout()
        
        DeunaSDK.config(
            apiKey: apiKey,
            orderToken: currentToken,
            userToken: "-",
            environment: .development, // or .production based on your need
            presentInModal: false, // Default: false , show the checkout in a pagesheet
            showCloseButton: true  // Default: true  ; Show a close button when
            
//            closeOnEvents: [.purchaseRejected]
//            closeOnSuccess: false
    //      keepLoaderVisible: true // Default: false ; Use to keep the loader visible after closing the checkout, this would give you a manual control on when to hide it
        )
    }
   
    var body: some View {
        if showThankYouView {
            ThankYouView(showThankYouView: $showThankYouView)
        } else {
            let imageUrl = URL(string: "https://camo.githubusercontent.com/50fa432906fc45b20062b150933db8f0bb86682ec6540624a19a72c59eb20d81/68747470733a2f2f642d756e612d6f6e652e73332e75732d656173742d322e616d617a6f6e6177732e636f6d2f67657374696f6e61646f5f706f725f642d756e612e706e67")!
            
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    URLImage(url: imageUrl)
                        .frame(height: 50)  // Adjust height as needed
                        .padding()
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Your cart")
                        .font(.title)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ProductRow(productName: "Hoodie", quantity: "2", price: "€30.00")
                        ProductRow(productName: "Hat", quantity: "1", price: "€20.00")
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("USD 50.00")
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Shipping")
                        Spacer()
                        Text("Free")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text("USD 50.00")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    Text("Current Token:")
                        .padding()
                    Text("\(currentToken)")
                        .padding()
                    HStack {
                        TextField("Enter token", text: $inputToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: setOrderToken) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()

                    VStack {
                        Spacer()
                        Button("Pagar") {
                            // Define callbacks here
                            let callbacks = DeunaSDK.Callbacks()
                            callbacks.onSuccess = { message in
                                // Handle success case
                                print("onSuccess")
                                
                                self.showThankYouView = true
                            }
                            
                            callbacks.onError = { error in
                                print("onError Callback")
                                // Handle error case
                                print(error)
                                
                                DeunaSDK.shared.closeCheckout()
                            }
                            
                            callbacks.onClose = { webView in
                                // Handle close action
                                print("Close")
                                // DeunaSDK.shared.hideLoader() // Call this method to hide the loader manually if the config property keepLoaderVisible is set to true
                            }
                            DeunaSDK.shared.initCheckout(callbacks: callbacks)
                        }
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 60)
                        
                        Button("Guardar método de pago") {
                            // Define callbacks here
                            let callbacks = DeunaSDK.Callbacks()
                            callbacks.onSuccess = { message in
                                // Handle success case
                                print("onSuccess")
                            }
                            
                            callbacks.onError = { error in
                                print("onError Callback")
                                
                                DeunaSDK.shared.closeCheckout()
                                // Handle error case
                                print(error)
                            }
                            
                            callbacks.onClose = { webView in
                                // Handle close action
                                print("Close")
                                // DeunaSDK.shared.hideLoader() // Call this method to hide the loader manually if the config property keepLoaderVisible is set to true
                            }
                            DeunaSDK.shared.initElements(callbacks: callbacks)
                        }
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .foregroundColor(.blue)
                        Spacer()
                    }
                    
                }
                .padding()
            }
        }
    }
    
    func setOrderToken() {
        DeunaSDK.shared.setOrderToken(newOrderToken: inputToken)
        currentToken = inputToken // Update the current token display
    }
    
    func clearCurrentToken() {
            currentToken = ""
            inputToken = ""
        }
    
}

struct ThankYouView: View {
    @Binding var showThankYouView: Bool
    
    var body: some View {
        VStack {
            Text("¡Gracias por tu compra!")
                .font(.title)
                .padding()
            Button("Regresar") {
                showThankYouView = false
            }
            // Agrega cualquier otro contenido que desees mostrar en la vista de agradecimiento.
        }
    }
}

struct ProductRow: View {
    var productName: String
    var quantity: String
    var price: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(productName)
                Text(quantity)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(price)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    func load(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct URLImage: View {
    @StateObject private var loader = ImageLoader()
    let url: URL
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                // Placeholder while the image is loading
                Color.gray
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}


struct SuccessView: View {
    @Binding var showSuccessView: Bool
    var clearToken: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            Text("Payment Successful")
                .font(.title)
            Text("Thank you for your purchase!")
                .font(.subheadline)
            Button("Continue Shopping") {
                clearToken()
                showSuccessView = false
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}
