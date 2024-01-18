import SwiftUI
import UIKit
import DeunaSDK

struct OptionsView: View {
    @Binding var selectedEnvironmentIndex: Int
    @Binding var apiKey: String
    @Binding var orderToken: String
    @Binding var userToken: String
    
    var onPayAction: () -> Void
    var onSavePaymentMethodAction: () -> Void
    
    var body: some View {
        VStack {
            // Botón para Pagar
            Button("Pagar", action: onPayAction)
                .padding()
                .frame(maxWidth: .infinity) // Ocupa el ancho completo
                .background(Color.blue) // Color azul para el fondo
                .foregroundColor(.white) // Texto en color blanco
                .cornerRadius(10)
            
            // Botón para Guardar Método de Pago
            Button("Guardar método de pago", action: onSavePaymentMethodAction)
                .padding()
                .frame(maxWidth: .infinity) // Ocupa el ancho completo
                .background(Color.blue) // Color azul para el fondo
                .foregroundColor(.white) // Texto en color blanco
                .cornerRadius(10)
            
            Spacer().frame(height: 80)
            
            Picker("Environment", selection: $selectedEnvironmentIndex) {
                Text("Development").tag(Environment.development.rawValue)
                Text("Staging").tag(Environment.staging.rawValue)
                Text("Production").tag(Environment.production.rawValue)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal) // Aplicar padding solo horizontalmente
            
            TextField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal) // Aplicar padding solo horizontalmente
            
            TextField("Order Token", text: $orderToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal) // Aplicar padding solo horizontalmente
            
            TextField("User Token", text: $userToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal) // Aplicar padding solo horizontalmente
        }
    }
}

class EnvironmentSelection: ObservableObject {
    @Published var selectedEnvironmentIndex: Int = Environment.development.rawValue
}
