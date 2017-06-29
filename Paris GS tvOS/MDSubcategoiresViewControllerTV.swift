//
//  MDSubcategoiresViewControllerTV.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 06-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import SDWebImage

class MDSubcategoiresViewControllerTV: UIViewController {

    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    var appDelegate: AppDelegate!
    var imageName = ""
    var titleCategory = ""
    var subTitleCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nameImage = imageName.replacingOccurrences(of: "https", with: "http")
        self.img.sd_setImage(with: URL.init(string: nameImage), placeholderImage: UIImage.init(named: ""))
        self.lbTitle.text = titleCategory 
        self.lbDescription.text = subTitleCategory
        
        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // oneTime = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.doInstructions), name:NSNotification.Name(rawValue: "Subcategories"), object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func doInstructions(_ notification: Notification)  {
        let message = notification.object as! Dictionary<String,AnyObject>
        if(message["action"] as! String == "chanceSubCategory")
        {
            let viewController = MDSubcategoiresViewControllerTV()
            viewController.imageName = message["image"] as! String
            viewController.titleCategory = message["title"] as! String
            viewController.subTitleCategory = message["subtitle"] as! String
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    deinit {
        print("MDSubcategories is being deallocated")
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
