//
//  MDSession.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 04-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import CoreLocation

class MDSession: NSObject {
    
    static var tokenSession: String!
    static var UUIDAppleTV = ""
    static var listDevices = Array<MDDevice>()
    static var listStores = Array<MDStore>()
    static var sales_code: String!
    static var id: Int!

    init? (attributes: Dictionary<String, AnyObject>)
    {
        for (key, value) in attributes {
            print(key)
            if(key == "tokensession")
            {
                if((value as! String).isEmpty){ return nil }
                MDSession.tokenSession = value as! String
            }
        }
    }
    
    static func loginWithUser(username: String, password: String, location: CLLocation?, hasError: @escaping (Bool) -> ())
    {
        var location = location
        var pushToken = UserDefaults.standard.object(forKey: "pushToken")
        var UUID = UserDefaults.standard.object(forKey: "UUID")
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        var enviroment = "production"
        let device = "ios"
        
        #if SIMULATOR
            // simulator only code
            location = CLLocation.init(latitude: -33.391158, longitude: -70.546995)
            enviroment = "development"
            UUID = "123"
        #endif
      
        var latitude: NSNumber
        var longitude: NSNumber
       
        if(location != nil)
        {
            latitude = NSNumber.init(value: location!.coordinate.latitude)
            longitude = NSNumber.init(value: location!.coordinate.longitude)
        }
        else
        {
            latitude = NSNumber.init(value: 0)
            longitude = NSNumber.init(value: 0)
        }
        
        if(pushToken == nil)
        {
            pushToken = "development"
        }
        
        if(UUID == nil)
        {
            print("UUID is:", UUID)
            let alertController = UIAlertController.init(title: "Error de parametros", message: "UUID es null", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
           
            alertController.addAction(ok)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            let user = ["user_name":username, "password": password]
            let device = ["device_type": device, "push_token": String(describing: pushToken!), "uuid": String(describing: UUID!), "environment": enviroment, "latitude":  String(describing: latitude), "longitude": String(describing: longitude)]
            let environment = ["application":"Guided Selling", "version": String(describing: versionNumber!), "build":String(describing: buildNumber!)]
            
            let parameters = ["session": ["user": user, "device": device , "environment": environment]]
            
            print("parameters: ", parameters)
            
            let path = kWSLogin
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary

                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            var profile = json["profile"].dictionaryObject
                            MDSession.id = profile?["id"] as! Int
                            let message = data!["message"]?.string
                            if(message != nil)
                            {
                                let alertController = UIAlertController.init(title: "Error Sesion", message:message, preferredStyle: .alert)
                                let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                                    alertController.dismiss(animated: true, completion: nil)
                                })
                                
                                alertController.addAction(ok)
                                
                                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                                
                                hasError(true)

                            }
                            else
                            {
                                print("login success")
                                MDSession.tokenSession = data!["token"]?.stringValue
                                print(MDSession.tokenSession)
                                UserDefaults.standard.set(MDSession.tokenSession, forKey: "token")
                                UserDefaults.standard.synchronize()
                            
                                for store in json["stores"].arrayObject!
                                {
                                    let store = MDStore.init(attributes: store as! Dictionary<String, AnyObject>)
                                    if(store != nil)
                                    {
                                        MDSession.listStores.append(store!)
                                    }
                                }
                                
                                hasError(false)
                            }
                        }
                    }
                    else
                    {
                        hasError(true)
                    }
                    },failure: { ( error: Error) in
                        hasError(true)
                })
            }
            else
            {
                hasError(true)
            }
        }
    
    }
    
    
    static func logout(hasError: @escaping (Bool) -> ())
    {
        
        let parameters = ["session":["token": MDSession.tokenSession!]]
        
        print("parameters: ", parameters)
        
        let path = kWSLogout
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["message"].string

                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        if(data == "Session successfully closed")
                        {
                            hasError(false)
                        }
                        else
                        {
                            hasError(true)
                        }
                    }
                }
                else
                {
                    hasError(true)
                }
                },failure: { ( error: Error) in
                    hasError(true)
            })
        }
        else
        {
            hasError(true)
        }

        
    }
    
    static func getUserSalesCode(rut: String, hasError: @escaping (Bool) -> ())    {
        
        let path = kWSUserSalesCode + rut
 
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationGET(withEndPoint: path, parameters: nil, success: { (jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].dictionaryObject
                    print(json)
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        MDSession.sales_code = data?["sales_code"] as! String
                        hasError(false)
                    }

                }
                else
                {
                    hasError(true)
                }
                
                },failure: { (error: Error?) in
                    hasError(true)
                    
            })
        }
        else
        {
            hasError(true)
        }
        
        
    }

    
    static func getLinkableDevices( hasError: @escaping (Bool) -> ())    {
        
        let path = kWSLinkeableDevices
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: nil, success: { (jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].arrayObject
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        for device: Any in data!
                        {
                            let device = MDDevice.init(attributes: device as! Dictionary<String, AnyObject>)
                            if(device != nil)
                            {
                                MDSession.listDevices.append(device!)
                            }
                        }
                        hasError(false)
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
    
    static func linkDevice( deviceID: Int, hasError: @escaping (Bool) -> ())    {
        let parameters = ["device": ["id": deviceID]]
        
        print("parameters: ", parameters)
        
        let path = kWSLinkDevice
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].bool
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        hasError(!data!)
                    }
                }
                else
                {
                    hasError(true)
                }
                },failure: { (error: Error?) in
                    hasError(true)
                    
            })
        }
        else
        {
            hasError(true)
        }

        
    }

    
    static func changePasswordFistTime(username: String, password: String, newPassword: String, hasError: @escaping (Bool) -> ())
    {
        let parameters = ["user": username, "oldPass": password, "newPass": newPassword]
        
        print("parameters: ", parameters)
        
        let path = ""//kWSChangePass
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].dictionary
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        if(data!["message"]?.stringValue == "Cierre de Sesión")
                        {
                            hasError(false)
                        }
                        else
                        {
                            hasError(true)
                        }
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
    
    static func recoverPass(email: String, hasError: @escaping (Bool) -> ())
    {
        let parameters = ["email": email]
        
        print("parameters: ", parameters)
        
        let path = kWSRecoverPass
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["class"].string
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        if(data == "success")
                        {
                            hasError(false)
                        }
                        else
                        {
                            hasError(true)
                        }
                    }
                }
                else
                {
                    hasError(true)
                }
                },failure: { (error: Error?) in
                    hasError(true)
            })
        }
        else
        {
            hasError(true)
        }

    }

}
