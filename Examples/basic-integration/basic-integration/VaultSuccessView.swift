//
//  SuccessView.swift
//  basic-integration
//
//  Created by Darwin Morocho on 8/3/24.
//

import Foundation
import SwiftUI

struct VaultSuccessView: View{
    public let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Card saving successful")
            
            Button(
                action: onBack
            ){
                Text("Go back").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
            
        }.padding()
    }
    
}


#Preview {
    VaultSuccessView(onBack: {})
}
