import SwiftUI
import Combine

// Enumeración para las opciones de entorno
enum EnvironmentOption: String, CaseIterable, Identifiable {
    case staging, development, production
    var id: String { self.rawValue }
}

// Vista para mostrar un agradecimiento post-compra
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
        }
    }
}

struct SavedCardSuccessView: View {
    @Binding var showSavedCardSuccess: Bool

    var body: some View {
        VStack {
            Text("¡Tarjeta guardada!")
                .font(.title)
                .padding()
            Button("Regresar") {
                showSavedCardSuccess = false
            }
        }
    }
}


// Fila de producto para el carrito de compras
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

// Vista para mostrar una imagen cargada desde URL
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

// Vista para mostrar el éxito del pago
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
