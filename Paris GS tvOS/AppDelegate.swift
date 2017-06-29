//
//  AppDelegate.swift
//  Paris GS tvOS
//
//  Created by Sarai Henriquez on 10-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import FCUUID

//let kFormatPrice = "$ %.00f"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AsyncServerDelegate {
    
    var window: UIWindow?
    var server = AsyncServer()
    var navegationController: UINavigationController!
    let userDefault = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.server.serviceType = "_ClientServer._tcp"
        self.server.serviceName = FCUUID.uuidForDevice()
        self.server.delegate = self
        self.server.start()
        
        #if SIMULATOR
            // simulator only code
           self.server.serviceName = "simulator"
        #endif

        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()

        navegationController = UINavigationController.init(rootViewController: MDScreenSaver())
        self.window?.rootViewController = navegationController
        
        print(FCUUID.uuidForDevice(), UIDevice.current.name)
        
        let domain = userDefault.value(forKey: kKeyBaseUrl) as? String
        if(domain == nil)
        {
            userDefault.set(MDTools.kWSURLProduction, forKey: kKeyBaseUrl)
            userDefault.synchronize()
        }
     
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func server(_ theServer: AsyncServer!, didConnect connection: AsyncConnection!) {
        print("didconnect")
        print(connection)
    }
    
    
    func server(_ theServer: AsyncServer!, didReceiveCommand command: AsyncCommand, object: Any!, connection:
        AsyncConnection!) {
            print("didreceivecommand")
            print(object)
            let message = object as! Dictionary<String,AnyObject>
            
            if(message["token"] as? String == MDSession.tokenSession )
            {
                if(message["page"] as! String ==  "ScreenSaver")
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ScreenSaver"), object: object)
                }
                if(message["page"] as! String ==  "Categories")
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Categories"), object: object)
                }
                if(message["page"] as! String ==  "Subcategories")
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Subcategories"), object: object)
                }
                if(message["page"] as! String ==  "ResultProducts")
                {
                    if(!(self.navegationController.visibleViewController is MDResultProductViewController))
                    {
                        let viewController = MDResultProductViewController()
                        NotificationCenter.default.addObserver(viewController, selector: #selector(viewController.loadProducts), name:NSNotification.Name(rawValue: "ResultProducts"), object: nil)
                        self.navegationController.pushViewController(viewController, animated: true)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ResultProducts"), object: object)
                }
                if(message["page"] as! String ==  "CompareProducts")
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "CompareProducts"), object: object)
                }
                if(message["page"] as! String ==  "ProductDetails")
                {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ProductDetails"), object: object)
                }
                if(message["page"] as! String ==  "Pay")
                {
                    if(!(self.navegationController.visibleViewController  is MDPayViewControllerTV))
                    {
                        self.navegationController.pushViewController(MDPayViewControllerTV(), animated: true)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Pay"), object: object)
                }
                
                if(message["action"] as! String == "goToHome")
                {
                    if(!(self.navegationController.visibleViewController is MDCategoriesViewControllerTV))
                    {
                        navegationController = UINavigationController.init(rootViewController: MDCategoriesViewControllerTV())
                        self.window?.rootViewController = navegationController
                        self.navegationController.popToRootViewController(animated: true)
                    }
                }
                if(message["action"] as! String == "goToSubCategory")
                {
                    let viewController = MDSubcategoiresViewControllerTV()
                    viewController.imageName = message["image"] as! String
                    viewController.titleCategory = message["title"] as! String
                    viewController.subTitleCategory = message["subtitle"] as! String
                    self.navegationController.pushViewController(viewController, animated: true)
                }
                if(message["action"] as! String == "goToSubCategoryRoot")
                {
                    navegationController = UINavigationController.init(rootViewController: MDCategoriesViewControllerTV())
                    self.window?.rootViewController = navegationController

                    let viewController = MDSubcategoiresViewControllerTV()
                    viewController.imageName = message["image"] as! String
                    viewController.titleCategory = message["title"] as! String
                    viewController.subTitleCategory = message["subtitle"] as! String
                    self.navegationController.pushViewController(viewController, animated: false)
                }
                if(message["action"] as! String == "continueToShoppingCart")
                {
                    self.navegationController.pushViewController(MDPayViewControllerTV(), animated: true)
                }
                if(message["action"] as! String == "back" )
                {
                    self.navegationController.popViewController(animated: true)
                }
                
                if(message["action"] as! String == "AppTimeOut" || message["action"] as! String == "close_app")
                {
                    if(!(self.navegationController.visibleViewController is MDScreenSaver))
                    {
                        navegationController = UINavigationController.init(rootViewController: MDScreenSaver())
                        self.window?.rootViewController = navegationController
                        self.navegationController.popToRootViewController(animated: true)
                    }
                }
                if(message["action"] as! String == "desvincular")
                {
                     MDSession.is_controlled = false
                    if(!(self.navegationController.visibleViewController is MDScreenSaver))
                    {
                        navegationController = UINavigationController.init(rootViewController: MDScreenSaver())
                        self.window?.rootViewController = navegationController
                        self.navegationController.popToRootViewController(animated: true)
                    }            
                    
                }
                if(message["action"] as! String == "linked")
                {
                     MDSession.is_controlled = true
                }
                
            }
    }
    
    
    func server(_ theServer: AsyncServer!, didDisconnect connection: AsyncConnection!) {
        print("disconnected server")
    }
    
    func server(_ theServer: AsyncServer!, didFailWithError error: Error!) {
        print("didfail")
    
    }
    
    @IBAction func goBack(_ sender: Any)  {
        self.navegationController.popViewController(animated: false)
    }
    
    
    
}

