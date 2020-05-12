//
//  Recorder.swift
//  ReplayKit12
//
//  Created by Bhoomika on 09/01/20.
//  Copyright © 2020 Bhoomika. All rights reserved.
//

import Foundation
import Photos
import ReplayKit
import AVKit

class ScreenRecorder
{
    var assetWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    static let albumName = "HomeCam"
    static let sharedInstance = ScreenRecorder()
    private static var assetCollection: PHAssetCollection!
    var fileUrl:URL?
    
    func startRecording(withFileName fileName: String, recordingHandler:@escaping (Error?)-> Void)
    {
        if #available(iOS 11.0, *)
        {
               
            let fileURL = URL(fileURLWithPath: ReplayFileUtil.filePath(fileName))
            self.fileUrl    =   fileURL
            assetWriter = try! AVAssetWriter(outputURL: fileURL, fileType:
                AVFileType.mp4)
            let videoOutputSettings: Dictionary<String, Any> = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : UIScreen.main.bounds.size.width,
                AVVideoHeightKey : UIScreen.main.bounds.size.height
            ];
            var channelLayout = AudioChannelLayout.init()
            channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_MPEG_5_1_D
            let audioOutputSettings: [String : Any] = [
                AVNumberOfChannelsKey: 6,
                AVFormatIDKey: kAudioFormatMPEG4AAC_HE,
                AVSampleRateKey: 44100,
                AVChannelLayoutKey: NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout)),
                ]
            
            videoInput  = AVAssetWriterInput (mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
            audioInput  = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)

            videoInput.expectsMediaDataInRealTime = true
            audioInput.expectsMediaDataInRealTime = true

            assetWriter.add(videoInput)
            assetWriter.add(audioInput)

            
            RPScreenRecorder.shared().startCapture(handler: { (sample, bufferType, error) in
                RPScreenRecorder.shared().isMicrophoneEnabled = true
                recordingHandler(error)
        
                if CMSampleBufferDataIsReady(sample)
                {
                    if self.assetWriter.status == AVAssetWriter.Status.unknown
                    {
                        self.assetWriter.startWriting()
                        self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    }
                    
                    if self.assetWriter.status == AVAssetWriter.Status.failed {
                        print("Error occured, status = \(self.assetWriter.status.rawValue), \(self.assetWriter.error!.localizedDescription) \(String(describing: self.assetWriter.error))")
                        return
                    }
                    
                    if (bufferType == .video)
                    {
                        if self.videoInput.isReadyForMoreMediaData
                        {
                            self.videoInput.append(sample)
                        }
                    }
                    if (bufferType == .audioApp) || (bufferType == .audioMic)
                    {
                        if self.audioInput.isReadyForMoreMediaData
                        {
                            //print("Audio Buffer Came")
                            self.audioInput.append(sample)
                        }
                    }
                }
                
            }) { (error) in
                recordingHandler(error)
//               debugPrint(error)
            }
        } else
        {
            // Fallback on earlier versions
        }
    }
    
    func stopRecording(handler: @escaping (Error?) -> Void)
    {
        if #available(iOS 11.0, *)
        {
            RPScreenRecorder.shared().stopCapture
            {    (error) in
                self.videoInput.markAsFinished()
                self.audioInput.markAsFinished()
                    handler(error)
                self.assetWriter.finishWriting {
                    
                    self.assetWriter = nil;
                    if let url  =   self.fileUrl{
                        ScreenRecorder.sharedInstance.saveVideo(url: url)
                    }
                }
                print(ReplayFileUtil.fetchAllReplays())
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
extension ScreenRecorder {
    static func configure() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            ScreenRecorder.assetCollection = assetCollection
            return
        }else{
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized && ScreenRecorder.assetCollection == nil  {
                createAlbum()
            }else{
                PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                    if status == .authorized{
                        createAlbum()
                    }else{
                        PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
                    }
                })
            }
        }
    }
}

extension ScreenRecorder {
    private static func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        }
    }
    
    private static func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: ScreenRecorder.albumName)
        }) { success, error in
            if success {
                ScreenRecorder.assetCollection = fetchAssetCollectionForAlbum()
            } else {
                print("error \(String(describing: error))")
            }
        }
    }
    
    private static func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", ScreenRecorder.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _ = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
}

extension ScreenRecorder {
//    func save(image: UIImage) {
//        guard  ScreenRecorder.assetCollection != nil  else { return }
//        PHPhotoLibrary.shared().performChanges({
//            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
//            let albumChangeRequest = PHAssetCollectionChangeRequest(for: ScreenRecorder.assetCollection)
//            let enumeration: NSArray = [assetPlaceHolder!]
//            albumChangeRequest!.addAssets(enumeration)
//        }, completionHandler: nil)
//    }
    
    func saveVideo(url: URL) {
        guard  ScreenRecorder.assetCollection != nil  else { return }
        
        PHPhotoLibrary.shared().performChanges({
            
        }) { (status, error) in
            if error == nil {
                
            }
        }
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: ScreenRecorder.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: nil)
    }
    
    
    func isAuthorize(_ completion: @escaping (Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            completion(true)
        }else{
            completion(false)
        }
        
    }
}

