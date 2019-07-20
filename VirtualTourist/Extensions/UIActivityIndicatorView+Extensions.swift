//
//  UIActivityIndicatorView+Extensions.swift
//  VirtualTourist
//
//  Created by Reem on 07/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    func stop() {
        self.stopAnimating()
        self.isHidden = true
    }
    func start()  {
        self.startAnimating()
        self.isHidden = false
    }
}
