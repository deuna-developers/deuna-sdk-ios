import Photos
import WebKit

extension DeunaWebViewController {
    
    /// Handles the snapshot result (common for all capture methods)
    private func handleSnapshotResult(image: UIImage?, error: Error?, completion: @escaping (UIImage?) -> Void) {
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
