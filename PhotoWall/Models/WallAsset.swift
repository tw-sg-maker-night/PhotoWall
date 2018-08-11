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

struct WallAsset: CustomStringConvertible {
    var identifier: String
    var imageUrl: URL
    var videoUrl: URL
    var width: Float

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
}
