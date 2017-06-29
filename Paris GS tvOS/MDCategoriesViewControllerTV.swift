//
//  MDCategoriesViewControllerTV.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 06-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCategoriesViewControllerTV: UIViewController {

    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // oneTime = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.doInstructions), name:NSNotification.Name(rawValue: "Categories"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doInstructions(_ notification: Notification) {
        let message = notification.object as! Dictionary<String,AnyObject>
        
        if(message["action"] as! String == "continueToSubCategories")
        {
            let viewController = MDSubcategoiresViewControllerTV()
            viewController.imageName = message["image"] as! String
            viewController.titleCategory = message["title"] as! String
            viewController.subTitleCategory = message["subtitle"] as! String
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    deinit {
        print("MDCategoiesView is being deallocated")
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
