//
//  DeunaSDK+Environment.swift
//

import Foundation
import UIKit

// MARK: - Public Enums
@objc public enum Environment: Int {
    case development
    case production
    case staging
    case sandbox
}


// MARK: - CloseButtonConfig Class
public class CloseButtonConfig {
    var title: String = "x"
    var titleColor: UIColor = .blue
    var backgroundColor: UIColor = .clear
    var frame: CGRect = CGRect(x: 10, y: 90, width: 60, height: 20) // Default to top right
    var icon: UIImage? = nil // Optional icon
    var onClose: (() -> Void)? // Closure para el evento de cierre
}
