//
//  MDTimerApp.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 13-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
let kApplicationTimeoutInMinutes = 1.5

class MDTimerApp: UIApplication {
    
    var myidleTimer: Timer?
    
    override func sendEvent(_ event: UIEvent)  {
        super.sendEvent(event)
        
        if (myidleTimer == nil) {
            
            self.resetIdleTimerWihtTimer()
        }
        
        let allTouches = event.allTouches
        if(allTouches != nil)
        {
            if((allTouches?.count)! > 0)
            {
                let phase: UITouchPhase = (allTouches?.first?.phase)!
                if(phase == UITouchPhase.began)
                {
                    self.resetIdleTimerWihtTimer()
                }
            }
        }
        
 
    }
    
    func resetIdleTimerWihtTimer()
    {
        if(myidleTimer != nil)
        {
            myidleTimer?.invalidate()
        }
        
        //convert the wait period into minutes rather than seconds
        let timeout = kApplicationTimeoutInMinutes * 60
        
        myidleTimer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(self.idleTimerExceeded), userInfo: nil, repeats: false)
    }
    
    func idleTimerExceeded() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)
    }
    
    
}
