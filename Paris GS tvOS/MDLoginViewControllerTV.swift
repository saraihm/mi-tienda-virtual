//
//  MDLoginViewControllerTV.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 05-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDLoginViewControllerTV: UIViewController {

    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add shadow to viewLogin
        self.viewLogin.layer.masksToBounds = false
        self.viewLogin.layer.shadowOffset = CGSize.init(width: 0, height: 5)
        self.viewLogin.layer.shadowRadius = 15
        self.viewLogin.layer.shadowOpacity = 0.3
        
        //Add border color and icon to textfields
        let icon = UIImageView.init(image: UIImage.init(named: "ic_user"))
        icon.frame = CGRect(x: 0, y: 0, width: 45, height: 20);
      //  self.txtUsuario.layer.borderColor = COLOR_BLUE_LIGHT.CGColor
       // self.txtUsuario.layer.borderWidth = 1.0;
        self.txtUsuario.leftView = icon;
        self.txtUsuario.leftViewMode = .always;
        
        let iconPass = UIImageView.init(image: UIImage.init(named: "ic_pass"))
        iconPass.frame = CGRect(x: 0, y: 0, width: 45, height: 20);
       // self.txtContrasena.layer.borderColor = COLOR_BLUE_LIGHT.CGColor
       // self.txtContrasena.layer.borderWidth = 1.0;
        self.txtContrasena.leftView = iconPass;
        self.txtContrasena.leftViewMode = .always;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
