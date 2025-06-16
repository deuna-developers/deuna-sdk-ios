//
//  BuildUI.swift
//  DeunaSDK
//
//  Created by DEUNA on 21/10/24.
//

import UIKit



extension DeunaWebViewController {
    /// Shows the activity indicator loader.
    func showLoader() {
        if activityIndicator != nil {
            return
        }
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator!.center = view.center
        view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
    }
    
    /// Hides the activity indicator loader.
    func hideLoader() {
        guard activityIndicator != nil else { return }
        activityIndicator!.removeFromSuperview()
        activityIndicator = nil
    }
    
    func addDismissLineBar() {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 40,
            y: 0,
            width: 80,
            height: 30
        )
        
        let lineBarHeight = 6
        let lineBar = UIView()
        lineBar.backgroundColor = .lightGray
        lineBar.frame = CGRect(
            x: Int(view.frame.width * 0.5) - 20,
            y: 10,
            width: 40,
            height: lineBarHeight
        )
        lineBar.layer.cornerRadius = 3
        view.addSubview(containerView)
        view.addSubview(lineBar)
    }
    
    
}
