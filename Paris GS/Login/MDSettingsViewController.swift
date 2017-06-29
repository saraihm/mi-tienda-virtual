//
//  MDSettingsViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 05-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSettingsViewController: UIViewController {

    @IBOutlet weak var btOk: UIButton!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lbServer: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewDropDown: UIView!

    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupChooseDropDown()
        
        viewDropDown.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showDropDown)))
        
        MDTools.addShadowTo(view: self.viewContent)
        
        //Blur effect
        imgBackground.image = imgBackground.image?.applyBlurWithRadius(blurRadius: 2, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.0)
        
        btOk.layer.cornerRadius = kCornerRadiusButton
        
        viewDropDown.layer.borderWidth = 1.0
        viewDropDown.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        
        if(UserDefaults.standard.value(forKey: kKeyBaseUrl) as! String == MDTools.kWSURLProduction)
        {
            self.lbTitle.text = "Producción"
        }
        else
        {
            self.lbTitle.text = "Test"
        }
        
        self.lbServer.text = UserDefaults.standard.value(forKey: kKeyBaseUrl) as! String
        
    }
    
    func setupChooseDropDown() {
        dropDown.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
        dropDown.customCellConfiguration = nil
        
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            
            cell.titleLabel.text = item.components(separatedBy: " ")[0]
            cell.optionLabel.text = item.components(separatedBy: " ")[1]
        }

        dropDown.anchorView = viewDropDown
        dropDown.textFont = UIFont.init(name: "AzoSans-Light", size: 18)!
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        dropDown.bottomOffset = CGPoint(x: 0, y: viewDropDown.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        dropDown.dataSource = [
            "Test http://jenkins.motiondisplays.cl:3000/",
            "Producción http://paris.motiondisplays.cl:3000/",
        ]
        
        
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.lbTitle.text = item.components(separatedBy: " ")[0]
            self.lbServer.text = item.components(separatedBy: " ")[1]
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }
    
   


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDropDown() {
        dropDown.show()
    }

    @IBAction func ready(_ sender: Any) {
        
        UserDefaults.standard.set(self.lbServer.text, forKey: kKeyBaseUrl)
        UserDefaults.standard.synchronize()
        MotionDisplaysApi.refreshBaseUrl()
        _ = self.navigationController?.popViewController(animated: false)
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
