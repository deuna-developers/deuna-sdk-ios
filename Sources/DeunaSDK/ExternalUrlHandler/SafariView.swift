//
//  SafariView.swift
//  DeunaSDK
//
//  Created by DEUNA on 6/6/25.
//
import Foundation
import SafariServices

class SafariView: NSObject, SFSafariViewControllerDelegate {
    static let shared = SafariView()
    var safariVC: SFSafariViewController? = nil
    var onDismiss: VoidCallback?

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        onDismiss?()
    }

    func open(url: URL, viewController: UIViewController, onDismiss: @escaping VoidCallback) {
        DispatchQueue.main.async {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            self.safariVC = SFSafariViewController(url: url, configuration: config)
            self.safariVC!.modalPresentationStyle = .fullScreen
            self.safariVC!.preferredControlTintColor = .systemBlue
            self.safariVC!.dismissButtonStyle = .close
            self.safariVC!.delegate = self

            viewController.present(self.safariVC!, animated: true)
            self.onDismiss = onDismiss
        }
    }

    func close() {
        safariVC?.dismiss(animated: true){
            self.onDismiss?()
            self.onDismiss = nil
        }
        safariVC = nil
    }
}
