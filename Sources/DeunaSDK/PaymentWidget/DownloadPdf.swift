//
//  DownloadPdf.swift
//  DeunaSDK
//
//  Created by DEUNA on 30/9/24.
//

import Foundation
import UIKit

extension PaymentWidgetViewController: UIDocumentPickerDelegate {
    func downloadPdf(urlString: String, completition: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            DeunaLogs.error("Invalid PDF URL")
            completition()
            return
        }

        guard #available(iOS 14.0, *) else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            completition()
            return
        }

        URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let localURL = localURL, let response = response as? HTTPURLResponse {
                // Check the MIME type to determine if it's a PDF
                if response.mimeType?.contains("pdf") ?? false {
                    // Move the file to a temporary location
                    let fileManager = FileManager.default
                    let tempDirectory = fileManager.temporaryDirectory
                    let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent).appendingPathExtension("pdf")

                    do {
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.moveItem(at: localURL, to: destinationURL)

                        // Present the document picker for the user to select the save location
                        DispatchQueue.main.async {
                            self.presentDocumentPicker(for: destinationURL)
                        }
                    } catch {
                        DeunaLogs.error("Error moving file: \(error)")
                    }
                } else {
                    // Handle non-PDF files (optional)
                    DeunaLogs.error("Downloaded file is not a PDF.")
                }

            } else if let error = error {
                DeunaLogs.error("Error downloading PDF: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                completition()
            }
        }.resume()
    }

    @available(iOS 14.0, *)
    func presentDocumentPicker(for fileURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
}
