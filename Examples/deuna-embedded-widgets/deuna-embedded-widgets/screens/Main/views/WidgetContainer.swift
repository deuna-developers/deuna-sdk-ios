import SwiftUI
import DeunaSDK

struct WidgetContainer: View {
    let deunaSDK: DeunaSDK
    @Binding var config: DeunaWidgetConfiguration?

    var body: some View {
        ZStack{
            if let config =  $config.wrappedValue {
                DeunaWidget(
                    deunaSDK: deunaSDK,
                    configuration: config
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
    }
}
