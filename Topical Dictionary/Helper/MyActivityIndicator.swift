//
//  MyActivityIndicator.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 18.09.2021.
//  Copyright © 2021 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyActivityIndicator: UIView {
    
    var activityIndicator: NVActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.1, alpha: 0.3)
        let indicatorColor = UIColor.white
        let indicatorWidth = frame.width/6
        
        let activityIndicatorFrame = CGRect(x: (frame.width - indicatorWidth)/2,
                                            y: (frame.height - indicatorWidth)/2,
                                            width: indicatorWidth, height: indicatorWidth)
        self.activityIndicator = NVActivityIndicatorView(frame: activityIndicatorFrame, type: .ballSpinFadeLoader, color: indicatorColor, padding: nil)
        self.activityIndicator?.startAnimating()
        addSubview(activityIndicator!)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func endActivity() {
        activityIndicator?.stopAnimating()
        activityIndicator?.willMove(toSuperview: nil)
        activityIndicator?.removeFromSuperview()
    }
    
}

extension UIView {
    
    func addMyActivityIndicator() -> MyActivityIndicator {
        let activityIndicator = MyActivityIndicator(frame: frame)
        
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.leadingAnchor.constraint(equalTo: activityIndicator.superview!.leadingAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: activityIndicator.superview!.topAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: activityIndicator.superview!.trailingAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo:  activityIndicator.superview!.bottomAnchor).isActive = true
        
        return activityIndicator
    }
}


