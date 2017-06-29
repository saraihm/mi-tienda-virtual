
//
//  ViewController.swift
//  Paris GS tvOS
//
//  Created by Sarai Henriquez on 10-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MDScreenSaver: UIViewController  {
    
    var player: AVPlayer! = nil
    var playerLayer: AVPlayerLayer!
    var appDelegate: AppDelegate!
    let lbNameAppleTv = UILabel.init(frame: CGRect(x: 40, y: 0, width: 1080, height: 60))
    let settings = UIButton.init(frame: CGRect(x: 980, y: 0, width: 120, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbNameAppleTv.font =  UIFont.init(name: "paris-semibold", size: 30)
        lbNameAppleTv.numberOfLines = 2
        
        settings.setImage(UIImage.init(named: "settings_filled"), for: .normal)
        settings.contentMode = .scaleToFill
        settings.addTarget(self, action: #selector(self.settingsAction), for:.primaryActionTriggered)


        let videoURL = URL(fileURLWithPath:Bundle.main.path(forResource: "Video_PARIS_FINAL_2.1", ofType:"mp4")!)
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        self.view.addSubview(lbNameAppleTv)
        self.view.addSubview(settings)
        player.play()
    
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    func settingsAction(){
       self.navigationController?.pushViewController(MDSettingViewController(), animated: false)
    }
    
    func playerItemDidReachEnd(_ notification: Notification)  {
        let player = notification.object
        (player as! AVPlayerItem).seek(to: kCMTimeZero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MDSession.registerDevices { (hasError: Bool) in
            if(!hasError)
            {
                if(MDSession.is_controlled)
                {
                    self.lbNameAppleTv.isHidden = true
                    self.settings.isHidden = true
                    
                }
                else
                {
                    self.lbNameAppleTv.isHidden = false
                    self.lbNameAppleTv.text = UIDevice.current.name
                    self.settings.isHidden = false 
                }
                
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.changeVideo), name:NSNotification.Name(rawValue: "ScreenSaver"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        if(playerLayer == nil)
        {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer)
            self.view.addSubview(lbNameAppleTv)
        }
        self.player.seek(to: kCMTimeZero)
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func changeVideo(_ notification: Notification) {
        let message = notification.object as! Dictionary<String,AnyObject>

        if(message["action"] as! String == "continueToCategories")
        {
            player.pause()
            playerLayer.removeFromSuperlayer()
            playerLayer = nil
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.pushViewController(MDCategoriesViewControllerTV(), animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("MDScreenSaver is being deallocated")
    }


}

