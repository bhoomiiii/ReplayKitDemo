//
//  VideosList.swift
//  ReplayKit12
//
//  Created by Bhoomika on 08/01/20.
//  Copyright © 2020 Bhoomika. All rights reserved.
//

import UIKit
import AVKit
import Photos

class VideosList: UIViewController {

    @IBOutlet weak var collectnVw: UICollectionView!
   // var dataAry = ReplayFileUtil.fetchAllReplays()
    @objc dynamic var videoPlayer: AVPlayerViewController!
    @objc dynamic var player: AVPlayer!
    var photos: [UIImage?] = []
    var arr: [AVAsset?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
         getAssetFromPhoto()

        do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.multiRoute)
            } catch let error as NSError {
                print(error)
            }

            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
        }
    func getAssetFromPhoto() {
     let options             = PHFetchOptions()
     options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
     let albumName = "HomeCam"
     var albumFound = Bool()
     var assetCollection = PHAssetCollection()
     var photoAssets = PHFetchResult<AnyObject>()
     let fetchOptions = PHFetchOptions()
     fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        

     let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

     if let firstObject = collection.firstObject{
         assetCollection = firstObject
         albumFound = true
     }
     else { albumFound = false }
     _ = collection.count
    
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
        photoAssets.enumerateObjects { (asset, index, bool) in
            guard let phasset = asset as? PHAsset else { return }
            if phasset.mediaType == .video {
                PHImageManager.default().requestImage(for: asset as! PHAsset , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { (image, userinfo) in
                    self.photos.append(image)
                }
                PHImageManager.default().requestAVAsset(forVideo: asset as! PHAsset , options: nil) { (avasset, mix, userinfo) in
                    self.arr.append(avasset)
                }
            }
        }
        self.collectnVw.reloadData()
    }
}

extension VideosList: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell
        cell?.thumbnail.image = photos[indexPath.item]
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.videoPlayer = AVPlayerViewController.init()
        guard let asset = arr[indexPath.row] else { return }
        let item = AVPlayerItem(asset: asset)
        videoPlayer.player = AVPlayer(playerItem: item)
        videoPlayer.view.frame = self.view.frame
        present(videoPlayer, animated: true, completion: nil)
        videoPlayer.player?.play()
    }
    
}

