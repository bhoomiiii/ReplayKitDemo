//
//  ViewController.swift
//  ReplayKit12
//
//  Created by Bhoomika on 06/01/20.
//  Copyright © 2020 Bhoomika. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    let screenRecoder = ScreenRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        ScreenRecorder.configure()

    }
    @IBAction func start(_ sender: Any) {
        loader.startAnimating()
        loader.isHidden = false
        let randomNumber = arc4random_uniform(9999);
        let name         = "iosreplay\(randomNumber)"
        RPScreenRecorder.shared().isMicrophoneEnabled = true
        screenRecoder.startRecording(withFileName: name) { (errr) in
            if errr == nil {
                print("Started")
            } else {
                print("End")
            }
        }
    }
    

    @IBAction func end(_ sender: Any) {
        loader.stopAnimating()
        loader.isHidden = true
        screenRecoder.stopRecording { (error) in
            if error == nil {
                print("Stop")
            }
        }
    }
    @IBAction func nextCV(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "VideosList") as! VideosList
        self.navigationController?.pushViewController(vc, animated: true)
        ReplayFileUtil.removeAllFile()
    }
    @IBAction func next(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "VideosListCV") as! VideosListCV
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

