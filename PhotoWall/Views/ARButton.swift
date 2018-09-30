//
//  ARButton.swift
//  PhotoWall
//
//  Created by Colin Harris on 8/29/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit

class ARButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = -1 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        if cornerRadius == -1 {
            self.layer.cornerRadius = self.frame.size.width / 2
        }
        self.layer.backgroundColor = UIColor(white: 1, alpha: 0.5).cgColor
    }
}
