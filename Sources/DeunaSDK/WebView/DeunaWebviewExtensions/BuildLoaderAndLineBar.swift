//
//  BuildUI.swift
//  DeunaSDK
//
//  Created by DEUNA on 21/10/24.
//

import UIKit

extension DeunaWebViewController {
    func setupLoader() {
        guard activityIndicator == nil else { return }
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.hidesWhenStopped = true
        
        guard let indicator = activityIndicator else { return }
        view.addSubview(indicator)
        
        // Constraints para centrar exactamente
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// Shows the activity indicator loader.
    func showLoader() {
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.setupLoader()
                
                if let indicator = self.activityIndicator {
                    indicator.startAnimating()
                    self.view.bringSubviewToFront(indicator)
                }
            }
        }
    }
        
    /// Hides the activity indicator loader.
    func hideLoader() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
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
