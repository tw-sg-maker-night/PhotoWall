//
//  LibraryController.swift
//  PhotoWall
//
//  Created by Colin Harris on 16/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit

class LibraryController: UICollectionViewController {
    
    var assets: [WallAsset] = []
    
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Move the loading of assets into a background thread and display a loading indicator
        self.assets = WallAssetStore().loadAssets()
        self.collectionView?.reloadData()
    }
    
}

extension LibraryController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as! AssetCell
        let asset = assetForIndexPath(indexPath: indexPath)
        cell.backgroundColor = UIColor.white
        cell.imageView.image = asset.image()
        return cell
    }
}

extension LibraryController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: (widthPerItem / 16) * 9)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

private extension LibraryController {
    func assetForIndexPath(indexPath: IndexPath) -> WallAsset {
        return assets[indexPath.row]
    }
}

