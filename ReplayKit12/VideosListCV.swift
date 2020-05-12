//
//  VideosListCV.swift
//  ReplayKit12
//
//  Created by Bhoomika on 06/01/20.
//  Copyright © 2020 Bhoomika. All rights reserved.
//

import UIKit
import AVKit

class VideosListCV: UIViewController {

    @IBOutlet weak var tbview: UITableView!

    var data = ReplayFileUtil.fetchAllReplays()
    override func viewDidLoad() {
        super.viewDidLoad()
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

}
extension VideosListCV: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell
        let url = data[indexPath.row]
        cell?.name.text = String(describing: url.absoluteString.lowercased())
        return cell!
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = data[indexPath.row]
        let videoPlayerController = AVPlayerViewController()
        //let player = AVPlayer()
        videoPlayerController.player = AVPlayer(url: url)
        videoPlayerController.view.frame = self.view.frame
        present(videoPlayerController, animated: true, completion: nil)
        videoPlayerController.player?.play()
    }
}
