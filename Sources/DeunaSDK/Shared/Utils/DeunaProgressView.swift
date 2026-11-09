import UIKit

internal class DeunaProgressView {

    private var overlayView: UIView?

    func show() {
        DispatchQueue.main.async {
            guard self.overlayView == nil,
                  let window = Self.keyWindow() else { return }

            let containerSize: CGFloat = 88
            let spinnerSize: CGFloat = 40

            let overlay = UIView(frame: window.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let circle = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
            circle.backgroundColor = .white
            circle.layer.cornerRadius = containerSize / 2
            circle.layer.shadowColor = UIColor.black.cgColor
            circle.layer.shadowOpacity = 0.15
            circle.layer.shadowRadius = 8
            circle.layer.shadowOffset = CGSize(width: 0, height: 2)
            circle.center = overlay.center
            circle.autoresizingMask = [
                .flexibleLeftMargin, .flexibleRightMargin,
                .flexibleTopMargin, .flexibleBottomMargin,
            ]

            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.frame = CGRect(
                x: (containerSize - spinnerSize) / 2,
                y: (containerSize - spinnerSize) / 2,
                width: spinnerSize,
                height: spinnerSize
            )
            spinner.startAnimating()

            circle.addSubview(spinner)
            overlay.addSubview(circle)
            window.addSubview(overlay)
            self.overlayView = overlay
        }
    }

    func dismiss() {
        DispatchQueue.main.async {
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        }
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
