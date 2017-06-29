//
//  MDSession.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 02-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import FCUUID

class MDSession: NSObject {

    static var tokenSession = FCUUID.uuidForDevice()
    static var is_controlling = false
    static var is_controlled = true
    
    static func registerDevices(hasError: @escaping (Bool) -> ())
    {
        
        var pushToken = UserDefaults.standard.object(forKey: "pushToken")
        var UUID = MDSession.tokenSession!
        let name = UIDevice.current.name
        let deviceModel = "tvos"
        var enviroment = "production"
        
        #if SIMULATOR
            // simulator only code
            MDSession.tokenSession = "simulator"
            enviroment = "development"
            UUID = "simulator"
            pushToken = "simulator"
        #endif

        pushToken = "pushToken"
        
        let device = ["device_type": String(describing: deviceModel), "push_token":String(describing: pushToken!), "environment":String(describing: enviroment), "uuid":String(describing: UUID), "name":String(describing: name)]
        let parameters = ["device":device]
          print("parameters: ", parameters)
        
          let path = "devices/register_device"
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    print(json)
                    let data = json["data"].bool

                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        MDSession.is_controlled = json["is_controlled"].bool!
                        MDSession.is_controlling = json["is_controlling"].bool!
                        hasError(!data!)
                    }
                }
                else
                {
                    hasError(true)
                }
                },failure: { (error: Error) in
                    hasError(true)
            })
        }
        else
        {
            hasError(true)
        }
    
    }

}
