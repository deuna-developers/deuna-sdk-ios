//
//  AutoResizeConfig.swift
//  DeunaSDK
//

import CoreGraphics

/// Configuration for the auto-resize behavior of an embedded widget.
///
/// Pass an instance of this class to the widget configuration to enable automatic
/// resizing to the WebView content height. The widget must be placed inside a
/// `ScrollView`.
///
/// - Parameter initialHeight: Optional initial height in points shown while the page loads.
public class AutoResizeConfig: NSObject {
    public let initialHeight: CGFloat?

    public init(initialHeight: CGFloat? = nil) {
        self.initialHeight = initialHeight
    }
}
