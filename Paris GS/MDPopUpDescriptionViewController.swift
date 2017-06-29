//
//  MDPopUpDescriptionViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 05-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDPopUpDescriptionViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UITextView!
    @IBOutlet var viewPopUp: UIView!
    var descriptionLong: String!
    var titleDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = UIScreen.main.bounds.size.width
        let heigth = UIScreen.main.bounds.size.height
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.frame = CGRect(x:0, y:0, width:width, height:heigth)
   //     self.viewPopUp.frame = CGRect(x:(width/2) - (375)/2, y:(heigth/2)-(221)/2, width:375, height: 221)
        self.lbDescription.text = descriptionLong
        self.lbTitle.text = titleDescription
        self.lbDescription.scrollsToTop = true
       
       // self.view.addSubview(viewPopUp)

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        lbDescription.setContentOffset(CGPoint.zero, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        // lbDescription.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removeFromView(_ sender: AnyObject) {
         self.dismiss(animated: true, completion: nil)
    }
    
  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
