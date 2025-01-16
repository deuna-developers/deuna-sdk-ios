import Photos
import WebKit

extension WKWebView {
    /// Take a screenshot of the current webview content and saves it into the PhotosLibrary
    /// - Parameters
    ///     - target: (Optional) The html target. For classes use '.' as prefix, for id use '#' as prefix. Example "#my-container".
    ///     - completion: Called when the task has finished.
    ///
    func takeSnapshot(target: String? = nil, completion: @escaping (UIImage?) -> Void) {
        // Check if the target starts with "#" or "."
        var js: String
        if let target = target {
            if target.hasPrefix("#") {
                // Capture by ID
                js = """
                (function() {
                    var element = document.querySelector('\(target)');
                    if (element) {
                        var rect = element.getBoundingClientRect();
                        return {
                            x: rect.left,
                            y: rect.top,
                            width: rect.width,
                            height: rect.height
                        };
                    } else {
                        return null;
                    }
                })();
                """
            } else if target.hasPrefix(".") {
                // Capture by class
                js = """
                (function() {
                    var element = document.querySelector('\(target)');
                    if (element) {
                        var rect = element.getBoundingClientRect();
                        return {
                            x: rect.left,
                            y: rect.top,
                            width: rect.width,
                            height: rect.height
                        };
                    } else {
                        return null;
                    }
                })();
                """
            } else {
                // If the target does not have a valid prefix, do not capture
                DeunaLogs.error("Target must start with '#' (ID) or '.' (class).")
                completion(nil)
                return
            }
            
            // Execute JavaScript to get the element's coordinates
            self.evaluateJavaScript(js) { result, error in
                if let error = error {
                    DeunaLogs.error("Error executing JavaScript: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // Check for a valid result
                if let dict = result as? [String: Any],
                   let x = dict["x"] as? CGFloat,
                   let y = dict["y"] as? CGFloat,
                   let width = dict["width"] as? CGFloat,
                   let height = dict["height"] as? CGFloat
                {
                    // Set up the rect to capture only the element's area
                    let snapshotConfig = WKSnapshotConfiguration()
                    snapshotConfig.rect = CGRect(x: x, y: y, width: width, height: height)
                    
                    // Take the snapshot
                    self.takeSnapshot(with: snapshotConfig) { image, error in
                        if let error = error {
                            DeunaLogs.error("Error taking snapshot: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }
                        
                        // Return the captured image
                        completion(image)
                        if let image = image {
                            self.saveImageToPhotosLibrary(image)
                        }
                    }
                } else {
                    DeunaLogs.error("Element not found or invalid dimensions.")
                    completion(nil)
                }
            }
        } else {
            // If no target is provided, capture the entire view
            let config = WKSnapshotConfiguration()
            config.rect = self.bounds // Capture the full visible WKWebView area

            self.takeSnapshot(with: config) { image, error in
                if let error = error {
                    DeunaLogs.error("Error taking snapshot: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // Return the captured image
                completion(image)
                
                if let image = image {
                    self.saveImageToPhotosLibrary(image)
                }
            }
        }
    }
    
    // Save image to Photos Library
    private func saveImageToPhotosLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                DeunaLogs.warning("Photo Library access denied.")
            }
        }
    }

    // Completion handler for when the image is saved
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            DeunaLogs.error("Error saving image: \(error.localizedDescription)")
            self.showAlert(message: "Error al guardar la imagen")
        } else {
            self.showAlert(message: "¡Imagen guardada con éxito!")
        }
    }

    // Method to show alert
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            if let viewController = self.getViewController() {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
                viewController.present(alert, animated: true, completion: nil)
            }
        }
    }
       
    // Helper method to get the parent view controller
    private func getViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
