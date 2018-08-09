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

struct WallAsset {
    var identifier: String
    var imageUrl: URL
    var videoUrl: URL
    var width: CGFloat

    func image() -> UIImage? {
        return UIImage(contentsOfFile: self.imageUrl.path)
    }

    func referenceImage() -> ARReferenceImage? {
        guard let image = image() else {
            return nil
        }

        let referenceImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: self.width)
        referenceImage.name = self.identifier
        return referenceImage
    }
}
