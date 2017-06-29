//
//  AppDelegate.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 22-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase
import FCUUID
import Fabric
import Crashlytics


//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AsyncClientDelegate {
    
    var window: UIWindow?
    var navigationController: ENSideMenuNavigationController!
    let client = AsyncClient()
    let userDefault = UserDefaults.standard
    var disconnect = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeout), name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        application.statusBarStyle = .lightContent
        
        client.serviceType = "_ClientServer._tcp"
        client.delegate = self
        client.start()
        
        let token = userDefault.value(forKey: "token") as? String
        let domain = userDefault.value(forKey: kKeyBaseUrl) as? String
        if(domain == nil)
        {
            userDefault.set(MDTools.kWSURLProduction, forKey: kKeyBaseUrl)
            userDefault.synchronize()
        }
        if(token == nil)
        {
            navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDLoginViewController())
        }
        else
        {
            MDSession.tokenSession = token
            if(userDefault.value(forKey: "linked_tv") != nil)
            {
                MDSession.UUIDAppleTV = userDefault.value(forKey: "linked_tv") as! String
            }
            if((userDefault.value(forKey: "store")) != nil)
            {
                MDSession.sales_code = userDefault.value(forKey: "store") as! String!
            }
            
            navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDWelcomeViewController())
        }
        
        self.window?.rootViewController = navigationController
        userDefault.set(FCUUID.uuidForDevice(), forKey: "UUID")
        userDefault.set(true, forKey: "showOnBoard")
        userDefault.synchronize()
        
        if((userDefault.object(forKey: "shoppingCart")) != nil)
        {
            MDShoppingCartViewController.shoppingCart.setShoppingCart(shoppingCart: userDefault.object(forKey: "shoppingCart") as! NSData)
        }
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if(cookie.name != "token")
                {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
        URLCache.shared.removeAllCachedResponses()
        
        Fabric.with([Crashlytics.self])

        return true
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()!
        print("InstanceID token: \(refreshedToken)")
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        // connectToFcm()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = NSString(format: "%@", deviceToken as CVarArg)
        token = token.replacingOccurrences(of:"<", with: "") as NSString
        token = token.replacingOccurrences(of:">", with: "") as NSString
        token = token.replacingOccurrences(of:" ", with: "") as NSString
        
        print("Device token: " + (token as String))
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.unknown)
        //   print("Device Token:", tokenString)
        userDefault.set(token as String, forKey: "pushToken")
        userDefault.synchronize()
    }
    
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                             fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        //  print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
        if (application.applicationState == .active ) {
            
            let localNotification = UILocalNotification()
            localNotification.userInfo = userInfo;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertBody = "";
            localNotification.fireDate = NSDate() as Date
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    private func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        
    }
    
    func forceLogin()
    {
        MotionDisplaysApi.cancelAllRequests()
        
        if(!(self.navigationController.presentedViewController is UIAlertController))
        {
            self.sendInstructionToParisTV(instruction: ["action": "desvincular" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page":"" as AnyObject])
            
            userDefault.removeObject(forKey: "token")
            userDefault.removeObject(forKey: "store")
            userDefault.removeObject(forKey: "shoppingCart")
            userDefault.removeObject(forKey: "linked_tv")
            userDefault.removeObject(forKey: "user_name")
            userDefault.removeObject(forKey: "id")
            MDShoppingCartViewController.shoppingCart.deleteAllProduct()
            MDCategoriesManager.categories.removeAll()
            MDSession.tokenSession = ""
            MDSession.UUIDAppleTV = ""
            MDSession.sales_code = nil
            MDSession.listDevices = Array<MDDevice>()
            MDSubcategoriesViewController.categoryId = nil
            MDFilterMenuViewController.productsId = Array<Int>()
            MDFilterMenuViewController.filters.filterWithProductsId = false
            
            navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDLoginViewController())
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: { self.window!.rootViewController = self.navigationController}) { (finished: Bool) in
                self.navigationController .popViewController(animated: true)
            }
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeout), name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if(disconnect)
        {
            client.stop()
            client.start()
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        self.sendInstructionToParisTV(instruction: ["action": "close_app" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page":"" as AnyObject])
    }
    
    
    func client(_ theClient: AsyncClient!, didFind service: NetService!, moreComing: Bool) -> Bool {
        
        print("didFindService")
        print(service.name)
        if(service.name == MDSession.UUIDAppleTV)
        {
            let alertController = UIAlertController.init(title: "", message:"Se ha establecido la conexión con el Apple TV", preferredStyle: .alert)
            
            let aceptar = UIAlertAction.init(title: "Aceptar", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            
            alertController.addAction(aceptar)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }
        
        return true
    }
    
    func client(_ theClient: AsyncClient!, didConnect connection: AsyncConnection!) {
        print("didConnect")
        disconnect = false
        print(theClient)
        
    }
    
    func client(_ theClient: AsyncClient!, didRemove service: NetService!) {
        
        print("didRemoveService")
        if(service.name == MDSession.UUIDAppleTV)
        {
            let alertController = UIAlertController.init(title: "Error", message:"Se ha perdido la conexión con el Apple TV", preferredStyle: .alert)
            
            let aceptar = UIAlertAction.init(title: "Aceptar", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            
            alertController.addAction(aceptar)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    func client(_ theClient: AsyncClient!, didDisconnect connection: AsyncConnection!) {
        print("diddisconnect")
        disconnect = true
        //  client.stop()
        //  client.start()
        print(theClient)
        
    }
    
    
    func client(_ theClient: AsyncClient!, didReceiveCommand command: AsyncCommand, object: Any!, connection: AsyncConnection!) {
        
        if(MDSession.UUIDAppleTV != "")
        {
            print("didreceivecommand:", object)
            let message = object as! Dictionary<String,AnyObject>
            if(message["token"] as! String == MDSession.UUIDAppleTV)
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationIdentifier"), object: message["index"] )
            }
        }
        
    }
    
    
    
    
    func client(_ theClient: AsyncClient!, didFailWithError error: Error!) {
        print("didfailwitherror: ", error)
    }
    
    
    func sendInstructionToParisTV(instruction: Dictionary<String,AnyObject>)
    {
        if(MDSession.UUIDAppleTV != "")
        {
            client.sendObject(instruction as NSCoding!)
        }
        
    }
    
    func applicationDidTimeout()  {
        print("tiempo muerto ", navigationController.visibleViewController ?? "")
        userDefault.set(true, forKey: "showOnBoard")
        userDefault.synchronize()
        if(window?.rootViewController?.presentedViewController is MDCompareProductsViewController || window?.rootViewController?.presentedViewController is MDCategoriesMenuViewController || window?.rootViewController?.presentedViewController is UIAlertController )
        {
            MotionDisplaysApi.cancelAllRequests()
            navigationController.dismiss(animated: false, completion: {
                self.navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDWelcomeViewController())
                self.window?.rootViewController = self.navigationController
                self.navigationController.popToRootViewController(animated: false)
                
            })
            
        }
        else if(!(navigationController.visibleViewController is MDWelcomeViewController) && !(navigationController.visibleViewController is MDLoginViewController) && !(navigationController.visibleViewController is MDWebViewPay) && !(navigationController.visibleViewController is MDLinkUpViewController) && !(navigationController.visibleViewController is MDSelectStorePopUpViewController) && !(navigationController.visibleViewController is MDValidateExperiencePopUpController))
        {
            MotionDisplaysApi.cancelAllRequests()
            //transition back
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDWelcomeViewController())
            //   navigationController.view.layer.add(transition, forKey: nil)
            window?.rootViewController = navigationController
            navigationController.popToRootViewController(animated: true)
            self.sendInstructionToParisTV(instruction: ["action": "AppTimeOut" as AnyObject, "page": "" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject])
            
        }
    }
    
    func FCUUIDsOfUserDevicesDidChangeNotification()  {
        
    }
    
}

extension NSURLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}
