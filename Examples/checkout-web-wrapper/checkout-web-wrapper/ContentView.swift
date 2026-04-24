import SwiftUI

struct ContentView: View {
    var body: some View {
        WebViewWrapper(
            url: URL(string: "https://explore.deuna.io")!,
            onJavascriptMesaageReceived: { message in
                
                switch message.callbackName {
                case .onSuccess:
                    print("Deuna: onSuccess")
                case .onError:
                    print("Deuna: onError: \(message.payload)")
                case .onEventDispatch:
                    
                    guard let event = message.payload["event"] as? String,
                        let data = message.payload["data"] as? [String:Any] else {
                        return
                    }
                    print("Deuna: onEventDispatch event: <--\(event)-->")
                    
                    if event == "onBinDetected" {
                        print("Deuna: metadata: \(String(describing: data["metadata"]))")
                    }
                    
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
