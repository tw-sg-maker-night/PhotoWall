//
//  LibraryController.swift
//  PhotoWall
//
//  Created by Colin Harris on 16/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import AWSCore

class LibraryController: UICollectionViewController {
    
    var assets: [WallAsset] = []
    var selectedAssets: [WallAsset] = []
    
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    let itemsPerRow: CGFloat = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Library"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(uploadClicked))
        
        collectionView?.allowsMultipleSelection = true
        collectionView?.allowsSelection = true
        collectionView?.contentInsetAdjustmentBehavior = .always
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Move the loading of assets into a background thread and display a loading indicator
        assets = WallAssetStore().loadAssets()
        collectionView?.reloadData()
    }
    
    @objc
    func trashClicked() {
        for asset in selectedAssets {
            WallAssetStore().delete(asset: asset)
            assets.removeAll(where: { $0 == asset })
        }
        collectionView.reloadData()
    }
    
    @objc
    func uploadClicked() {
        for asset in selectedAssets {
            RemoteStore().uploadAsset(asset: asset).continueOnSuccessWith { task -> AWSTask<AnyObject>? in
                if let error = task.error {
                    print("Upload Failed! - \(error.localizedDescription)")
                } else {
                    print("Upload Result = \(task.result!)")
                }
                return nil
            }
        }
        collectionView.reloadData()
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
        cell.checkedView.isHidden = !isSelected(asset)
        return cell
    }
    
    func isSelected(_ asset: WallAsset) -> Bool {
        return selectedAssets.contains(where: { $0 == asset })
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let asset = assetForIndexPath(indexPath: indexPath)
        if isSelected(asset) {
            selectedAssets.removeAll(where: { $0 == asset })
        } else {
            selectedAssets.append(asset)
        }
        return true
    }
    
    func playAssetVideo(asset: WallAsset) {
        let player = AVPlayer(url: asset.videoUrl)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            player.play()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.reloadData()
    }
}

extension LibraryController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * (2/3))
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

