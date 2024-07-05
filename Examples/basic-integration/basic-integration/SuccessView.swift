//
//  SuccessView.swift
//  basic-integration
//
//  Created by Darwin Morocho on 8/3/24.
//

import Foundation
import SwiftUI

struct SuccessView: View{
    
    var message: String
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
            
            Button(
                action: onBack
            ){
                Text("Go back").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
            
        }.padding()
    }
    
}


#Preview {
    SuccessView(message: "Payment successful!", onBack: {})
}
