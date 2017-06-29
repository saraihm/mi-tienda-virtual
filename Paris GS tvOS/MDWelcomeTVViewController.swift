//
//  MDWelcomeTVViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 12-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDWelcomeTVViewController: UIViewController {

    @IBOutlet weak var lbNameAppleTv: UILabel!
    var appDelegate: AppDelegate!
    let userDefault = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Config Paris iPad
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(userDefault.objectForKey("ipad_name") != nil)
        {
            lbNameAppleTv.hidden = true
        }
        else
        {
            lbNameAppleTv.hidden = false
            lbNameAppleTv.text = UIDevice.currentDevice().name
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        // oneTime = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.doInstructions), name:"Welcome", object: nil)
    }
   
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doInstructions(notification: NSNotification) {
        let message = notification.object as! Dictionary<String,AnyObject>
        
        if(message["action"] as! String == "continueToCategories")
        {
            let viewController = MDCategoriesViewControllerTV()
            viewController.imageName = message["image"] as! String
            viewController.titleCategory = message["title"] as! String
            viewController.subTitleCategory = message["subtitle"] as! String
            self.navigationController?.pushViewController(viewController, animated: true)
        }
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
