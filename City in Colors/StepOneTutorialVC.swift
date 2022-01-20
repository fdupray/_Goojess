//
//  StepOneTutorialVC.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import AVFoundation

class StepOneTutorialVC: UIViewController {
    
    @IBOutlet weak var videoBox: PlayerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.videoBox.player?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let path = Bundle.main.path(forResource: "CinC tut", ofType: "mp4")
        
        let pathURL = URL(fileURLWithPath: path!)
        
        let player = AVPlayer(url: pathURL)
        
        self.videoBox.player = player
        
        self.videoBox.player?.play()
        
        /*let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.videoBox.bounds
        
        self.videoBox.layer.addSublayer(playerLayer)
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        playerLayer.setNeedsDisplay()
        
        player.play()*/
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
}
