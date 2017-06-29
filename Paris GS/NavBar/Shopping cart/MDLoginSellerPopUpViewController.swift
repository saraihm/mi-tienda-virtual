//
//  MDLoginSellerPopUpViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 11-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDLoginSellerPopUpViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btContinue: UIButton!
    @IBOutlet weak var btYes: UIButton!
    @IBOutlet weak var txtRut: UITextField!
    @IBOutlet weak var lbInvalidRut: UILabel!
    @IBOutlet weak var btNo: UIButton!
    @IBOutlet var viewSecondPopUp: UIView!
    @IBOutlet var viewFirstPopUp: UIView!
    let shoppingCartManager = MDShoppingCarManager()
    let userDefault = UserDefaults.standard
    
    var fromCompareView = false
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let width = UIScreen.main.bounds.size.width
        let heigth = UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.frame = CGRect(x:0, y:0, width:width, height:heigth)
        
        self.viewFirstPopUp.frame = CGRect(x:width/2 - self.viewFirstPopUp.frame.size.width/2 , y:heigth/2 - self.viewFirstPopUp.frame.size.height/2, width:self.viewFirstPopUp.frame.size.width, height:self.viewFirstPopUp.frame.size.height)
        self.viewSecondPopUp.frame = CGRect(x:width, y:heigth/2 - self.viewSecondPopUp.frame.size.height/2, width:self.viewSecondPopUp.frame.size.width, height:self.viewSecondPopUp.frame.size.height)

        txtRut.delegate = self
        btNo.layer.cornerRadius = kCornerRadiusButton
        btNo.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        btNo.layer.borderWidth = 1.0
        btYes.layer.cornerRadius = kCornerRadiusButton
        btContinue.layer.cornerRadius = kCornerRadiusButton
        
        self.view.addSubview(viewFirstPopUp)
        self.view.addSubview(self.viewSecondPopUp)
        
        activityIndicator.hidesWhenStopped = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeout), name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func closePopUp(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func finalPopUp(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {
            if((self.userDefault.value(forKey: "store")) != nil)
            {
                MDSession.sales_code = self.userDefault.value(forKey: "store") as! String!
            }
            
            if(self.fromCompareView)
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.navigationController.pushViewController(MDWebViewPay(), animated: false)
            appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToShoppingCart" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
        })

        /*
        self.shoppingCartManager.newShoppingCart(hasError: { (hasError: Bool) in
            if(!hasError)
            {
                var count = 0
                for product in MDShoppingCartViewController.shoppingCart.products
                {
                    count += 1
                    self.shoppingCartManager.addProductShoopingCart(product: product, hasError: { (hasError: Bool) in
                        if(!hasError)
                        {
                            if(count == MDShoppingCartViewController.shoppingCart.products.count)
                            {
                                self.shoppingCartManager.publishShoopingCart(hasError: { (hasError: Bool) in
                                    if(!hasError)
                                    {
                                        self.dismiss(animated: true, completion: {
                                            
                                            if(self.fromCompareView)
                                            {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
                                            }
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            appDelegate.navigationController.pushViewController(MDWebViewPay(), animated: false)
                                            appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToShoppingCart" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
                                        })
                                    }
                                })
                            }
                        }
                    })
                }
                
            }
        })
*/
        
    }

    @IBAction func continueWithSecondPopUp(_ sender: AnyObject) {
        var newFrameFistPopUp = viewFirstPopUp.frame;
        newFrameFistPopUp.origin.x = -self.view.frame.size.width;
        var newFrameSecondPopUp = viewSecondPopUp.frame;
        newFrameSecondPopUp.origin.x = self.view.frame.size.width/2 - self.viewSecondPopUp.frame.size.width/2;
      
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.viewFirstPopUp.frame = newFrameFistPopUp
               self.viewSecondPopUp.frame = newFrameSecondPopUp
            }) { (Bool) in                
        }
        
      }
    
    @IBAction func continuePay(_ sender: AnyObject) {
       self.goToWebViewPay()
    }
    
    func goToWebViewPay()
    {
        self.view.endEditing(true)
        lbInvalidRut.isHidden = true
        if(txtRut.text?.isEmpty)!
        {
            lbInvalidRut.isHidden = false
        }
        else
        {
            if(CVZPChileanRUT.isValidRUT(txtRut.text))
            {
                self.btContinue.isHidden = true
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                MDSession.getUserSalesCode(rut: txtRut.text!, hasError: { (hasError: Bool) in
                    
                    if(!hasError)
                    {
                        DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            if(self.fromCompareView)
                            {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
                            }
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.navigationController.pushViewController(MDWebViewPay(), animated: false)
                            appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToShoppingCart" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
                            
                        })
                        }
                    }
                    else
                    {                        
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.btContinue.isHidden = false
                            self.activityIndicator.isHidden = true
                            self.lbInvalidRut.isHidden = false
                            self.viewSecondPopUp.setNeedsDisplay()
                            self.viewSecondPopUp.setNeedsLayout()
                        }
                    }
                })
                
            }
            else
            {
                lbInvalidRut.isHidden = false
            }
        }

    }
    
       

    //MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtRut)
        {
            self.goToWebViewPay()
        }
        
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
    }
    
    func animateTextField(textField: UITextField, up: Bool) {
        let movementDistance:CGFloat = -130
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        }
        else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    
    func applicationDidTimeout()  {
        print("tiempo muerto en vista login vendedor")
        self.dismiss(animated: false, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let set = NSCharacterSet(charactersIn: "0123456789kK").inverted
        return string.rangeOfCharacter(from: set) == nil
        
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
