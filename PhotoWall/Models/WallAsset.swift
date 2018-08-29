//
//  WallAsset.swift
//  PhotoWall
//
//  Created by Colin Harris on 9/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import ARKit

struct WallAsset: CustomStringConvertible, Equatable {
    var identifier: String
    var imageUrl: URL
    var videoUrl: URL
    var width: Float

    var imageFileName: String {
        return imageUrl.lastPathComponent
    }
    
    var videoFileName: String {
        return videoUrl.lastPathComponent
    }
    
    func image() -> UIImage? {
        return UIImage(contentsOfFile: self.imageUrl.path)
    }

    func referenceImage() -> ARReferenceImage? {
        guard let image = image() else {
            return nil
        }

        let referenceImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(self.width))
        referenceImage.name = self.identifier
        return referenceImage
    }
    
    static func == (lhs: WallAsset, rhs: WallAsset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
