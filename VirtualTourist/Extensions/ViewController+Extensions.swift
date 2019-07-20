//
//  ViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Reem on 05/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func showAlert(withTitle: String = "Alert", withMessage: String, action: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
}

