//
//  MDWelcomeViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDWelcomeViewController: UIViewController {
    
    @IBOutlet weak var btComenzar: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        self.navigationController?.isNavigationBarHidden = true;
        
        //Add shadow to button
        MDTools.addShadowTo(view: self.btComenzar)
        btComenzar.layer.cornerRadius = kCornerRadiusButton
        
        /*
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = 0.2
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        self.btComenzar.layer.add(pulseAnimation, forKey: "animateOpacity")*/
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        let alertController = UIAlertController.init(title: "Advertencia", message:"Receive memory warning", preferredStyle: .alert)
        
        let aceptar = UIAlertAction.init(title: "Aceptar", style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(aceptar)
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Button Action
    @IBAction func start(_ sender: AnyObject) {

        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Comienza Aquí" as NSObject,
            ])

        
        if(MDSession.UUIDAppleTV != "" && appDelegate.client.connections.count > 0)
        {
            for server in appDelegate.client.services.allObjects {
                var serv = server as! NetService
                print(serv.name)
                    
                if(serv.name == MDSession.UUIDAppleTV)
                {
                    continueToCategories()
                    return
                }
            }
     
            let alertController = UIAlertController.init(title: "Error", message:"No se ha podido establecer conexión con el Apple TV", preferredStyle: .alert)
            
            let aceptar = UIAlertAction.init(title: "Continuar", style: .cancel, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
                self.continueToCategories()
            })
            
            let reintentar = UIAlertAction.init(title: "Reintentar", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
                //self.appDelegate.client.stop()
                self.appDelegate.client.start()
            })

            
            alertController.addAction(aceptar)
            alertController.addAction(reintentar)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            continueToCategories()
        }

    }
    
    func continueToCategories()  {
        
       
        if(MDCategoriesManager.categories.count <= 0)
        {
            let loading = MDLoadingView.init(frame: self.view.bounds)
            loading.starLoding(inView: self.view)
            
            let categoriesManager = MDCategoriesManager()
            categoriesManager.getCategories( hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToCategories" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ScreenSaver" as AnyObject])
                    let viewController = MDCategoriesViewController()
                    viewController.descriptionString = categoriesManager.appSubTitle
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                
                loading.stopLoding()
            })
            
        }
        else
        {
            appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToCategories" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ScreenSaver" as AnyObject])
            let viewController = MDCategoriesViewController()
            viewController.descriptionString = ""
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }

    }
    
    deinit {
        print("MDWelcomeViewController is being deallocated")
    }


    /*


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
