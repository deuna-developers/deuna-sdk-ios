//
//  File.swift
//
//
//  Created by DEUNA on 20/9/24.
//

import Foundation
import UIKit

/// A class to convert and save a base64 image
class Base64ImageDownloader {
    let base64String: String
    let viewController: UIViewController

    init(_ base64String: String, viewController: UIViewController) {
        self.base64String = base64String
        self.viewController = viewController
    }

    func save() {
        guard let imageData = Data(base64Encoded: base64String.replacingOccurrences(of: "data:image/png;base64,", with: "")), let image = UIImage(data: imageData) else {
            DeunaLogs.error("Image cannot be created.")
            return
        }

        // Creates an activity view controller to share the image
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        // Shares the saved image
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
