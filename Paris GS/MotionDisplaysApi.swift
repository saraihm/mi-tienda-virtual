//
//  MotionDisplaysApi.swift
//  prueba
//
//  Created by Motion Displays on 09-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Alamofire

let kMDErrorInvalidSessionToken = "La sesión ha caducado, por favor inicie su sesión nuevamente"
let kMDErrorNullResponse = "Ha ocurrido un error durante el procesamiento de su solicitud"
let kWithoutInternetConnetion = "No se puede establecer conexión, verifique su configuración o solicite soporte al administrador de red."
let kKeyBaseUrl = "BaseUrl"

class MotionDisplaysApi {
    
    private var alamoFireManager : Alamofire.SessionManager!
    var isErrorMessagesActive = false
    var baseUrl: String!
    static let sharedInstance = MotionDisplaysApi()
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)

        self.refreshUrl()
    }
    
    static func jsonRequestOperationPOST(withEndPoint: String, parameters: Dictionary<String, Any>?, success: @escaping (Any?, Bool) -> (), failure: @escaping (Error) -> ())
    {
        
        let finalUrl = sharedInstance.baseUrl.appending(withEndPoint)
        
        print("finalURL: ", finalUrl)
        
        print("timeOut: ", sharedInstance.alamoFireManager.session.configuration.timeoutIntervalForRequest)
        
        sharedInstance.alamoFireManager.request(finalUrl, method: .post, parameters: parameters, encoding: URLEncoding.default).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                print("Validation Successful")
                success(response.result.value, handleErrorCode(json: response.result.value as Any))
            case .failure(let error):
                print(error.localizedDescription)
                
                if(error.localizedDescription == "The Internet connection appears to be offline."){
                    let alertController = UIAlertController.init(title: "Vuelve a intentar", message:"Se ha perdido la conexión a internet", preferredStyle: .alert)
                    
                    let ok = UIAlertAction.init(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationError"), object: nil)
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(ok)
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
                
                if(error.localizedDescription != "cancelled")
                {
                    let alertController = UIAlertController.init(title: "Error", message:error.localizedDescription, preferredStyle: .alert)
                    
                    let ok = UIAlertAction.init(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationError"), object: nil)
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(ok)
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
                
                
                failure(error)
            }
        }
    }
    
    static func jsonRequestOperationGET(withEndPoint: String, parameters: String?, success: @escaping (Any?, Bool) -> (), failure: @escaping (Error) -> ())
    {
        var finalUrl = ""
        if(parameters != nil)
        {
          finalUrl = sharedInstance.baseUrl.appending(withEndPoint).appending(parameters!)
        }
        else
        {
            finalUrl = sharedInstance.baseUrl.appending(withEndPoint)
        }
        
        print("finalURL: ", finalUrl)
        
        sharedInstance.alamoFireManager.request(finalUrl, method: .get).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                print("Validation Successful")
                success(response.result.value, handleErrorCode(json: response.result.value as Any))
            case .failure(let error):
                print(error.localizedDescription)
                
                if(error.localizedDescription != "cancelled")
                {
                    let alertController = UIAlertController.init(title: "Error", message:error.localizedDescription, preferredStyle: .alert)
                    
                    let ok = UIAlertAction.init(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationError"), object: nil)
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(ok)
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
                
                failure(error)
            }
        }
    }

    
    static func handleErrorCode(json: Any) -> Bool
    {
        var hasError = true
        var alertMsg: String?
        var errorCodeString = "Unknown"
        
        let jsonObject = JSON(json as AnyObject)
        let errorCode = jsonObject["data"].object
        let logout = jsonObject["logout"].object
        
        print(jsonObject)
        
        if(errorCode is NSNumber)
        {
            errorCodeString = String(describing: errorCode as! NSNumber)
            
            print("has error: ", errorCodeString)
            
            if(logout is NSNumber)
            {
                print("has error logout : ", logout)
                if((logout as! NSNumber).isEqual(to: 1))
                {
                    alertMsg = kMDErrorInvalidSessionToken
                    sharedInstance.isErrorMessagesActive = true
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.forceLogin()
                    
                }
                else
                {
                    alertMsg = jsonObject["message"].string
                    sharedInstance.isErrorMessagesActive = true
                }
            }
            else if ((errorCode as! NSNumber).isEqual(to: 0))
            {
                alertMsg = jsonObject["message"].string
                sharedInstance.isErrorMessagesActive = true
               
            }
            else
            {
                hasError = false
                print("hans't error")
            }
            
            if(alertMsg == nil)
            {
                alertMsg = kMDErrorNullResponse
            }
        }
        else
        {
            hasError = false
            print("hans't error")
        }
        
        
        if(hasError && sharedInstance.isErrorMessagesActive)
        {
            let alertController = UIAlertController.init(title: "Error \(errorCodeString)", message:alertMsg, preferredStyle: .alert)
            
            let ok = UIAlertAction.init(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationError"), object: nil)
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(ok)
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)

        }
        
        return hasError
        
    }
    
    static func internetConnection() -> Bool{
        
        if Reachability.isConnectedToNetwork() == true
        {
            print("Internet Connection Available!")
        }
        else
        {
            print("Internet Connection not Available!")
            
            let alertController = UIAlertController.init(title: "Conexion Internet", message:kWithoutInternetConnetion, preferredStyle: .alert)
            
            let ok = UIAlertAction.init(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationError"), object: nil)
                alertController.dismiss(animated: true, completion: nil)
                
            })
            
            alertController.addAction(ok)
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        
        return Reachability.isConnectedToNetwork()
    }
    
    static func refreshBaseUrl()
    {
        sharedInstance.refreshUrl()
    }
    
    static func cancelAllRequests() {
        print("cancelling MotionDisplaysApi requests")
        sharedInstance.alamoFireManager.session.invalidateAndCancel()
        sharedInstance.setAFconfig()
    }
    
    func setAFconfig(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60

        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func refreshUrl()
    {
        baseUrl = UserDefaults.standard.value(forKey: kKeyBaseUrl) as! String!
    }

    
    
}

