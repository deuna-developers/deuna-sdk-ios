//
//  WKNavigationActionDownloader.swift
//  DeunaSDK
//
//  Created by DEUNA on 22/10/24.
//

import WebKit

public enum FileExtension: String, CaseIterable {
    case pdf
    case doc
    case docx
    case xls
    case xlsx
    case ppt
    case pptx
    case zip
    case rar
    case tar
    case gz

    // Computed property to get the MIME type associated with each file extension
    var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .doc:
            return "application/msword"
        case .docx:
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .xls:
            return "application/vnd.ms-excel"
        case .xlsx:
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case .ppt:
            return "application/vnd.ms-powerpoint"
        case .pptx:
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case .zip:
            return "application/zip"
        case .rar:
            return "application/x-rar-compressed"
        case .tar:
            return "application/x-tar"
        case .gz:
            return "application/gzip"
        }
    }

    // Failable initializer to convert a string to a FileExtensions case
    init?(string: String) {
        guard !string.isEmpty else { return nil }
        self.init(rawValue: string.lowercased())
    }

    // Static method to get FileExtension from MIME type
    static func from(mimeType: String) -> FileExtension? {
        for fileExtension in FileExtension.allCases {
            if fileExtension.mimeType == mimeType {
                return fileExtension
            }
        }
        return nil // Return nil if no match is found
    }

    // Static property to get the list of all file extensions as strings
    static let allAsStrings: [String] = FileExtension.allCases.map { $0.rawValue }
}

extension URL {
    // Computed property to check if the URL is a file download URL
    var isFileDownloadUrl: Bool {
        return FileExtension.allAsStrings.contains(pathExtension.lowercased())
    }
}

extension BaseWebViewController: UIDocumentPickerDelegate {
    func downloadFile(urlString: String, fileExtension: FileExtension? = nil, completition: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            DeunaLogs.error("Invalid or unsupported file URL")
            completition()
            return
        }

        guard #available(iOS 14.0, *) else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            completition()
            return
        }

        URLSession.shared.downloadTask(with: url) { localURL, response, error in

            if let error = error {
                DeunaLogs.error("Error downloading file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completition()
                }
                return
            }

            guard let localURL = localURL, let response = response as? HTTPURLResponse else {
                DeunaLogs.error("Invalid response or no local URL")
                DispatchQueue.main.async {
                    completition()
                }
                return
            }

            var expectedMimeType: String?
            if let fileExtension = fileExtension {
                expectedMimeType = fileExtension.mimeType
            } else {
                expectedMimeType = response.mimeType
            }

            // Move the file to a temporary location
            let fileManager = FileManager.default
            let tempDirectory = fileManager.temporaryDirectory
            var destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

            if !destinationURL.isFileDownloadUrl, let fileExtension = FileExtension.from(mimeType: expectedMimeType ?? "")?.rawValue {
                destinationURL = destinationURL.deletingPathExtension().appendingPathExtension(fileExtension)
            }

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
