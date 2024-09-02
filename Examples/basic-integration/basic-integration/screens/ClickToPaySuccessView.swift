//
//  ClickToPaySuccessView.swift
//  basic-integration
//
//  Created by Darwin Morocho on 2/9/24.
//

import Foundation
import SwiftUI

struct ClickToPaySuccessView: View{
    public let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Click To Pay payment successful")
            
            Button(
                action: onBack
            ){
                Text("Go back").frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
            
        }.padding()
    }
    
}


#Preview {
    ClickToPaySuccessView(onBack: {})
}
