//
//  basic_integrationApp.swift
//  basic-integration
//
//  Created by DEUNA on 24/10/23.
//

import SwiftUI
import DeunaSDK

@main
struct basic_integrationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ViewModel(
                    deunaSDK: DeunaSDK(
                        environment: .sandbox,
                        publicApiKey: "YOUR_PUBLIC_API_KEY"
                    )
                )
            )
        }
    }
}
