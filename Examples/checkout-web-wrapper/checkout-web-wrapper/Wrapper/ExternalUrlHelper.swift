import SafariServices

// A class to handle external URLs like 3Ds or APMs redirects in a SFSafariViewController
class ExternalUrlHelper: NSObject, SFSafariViewControllerDelegate {
    static let shared = ExternalUrlHelper()
    var safariVC: SFSafariViewController? = nil

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("SFSafariViewController was dismissed manually.")
    }

    func open(url: URL) {
        DispatchQueue.main.async {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            self.safariVC = SFSafariViewController(url: url, configuration: config)
            self.safariVC!.modalPresentationStyle = .fullScreen
            self.safariVC!.preferredControlTintColor = .systemBlue
            self.safariVC!.dismissButtonStyle = .close
            self.safariVC!.delegate = self

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController
            {
                var topController = rootViewController
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(self.safariVC!, animated: true)
            }
        }
    }

    func close() {
        safariVC?.dismiss(animated: true)
        safariVC = nil
    }
}
