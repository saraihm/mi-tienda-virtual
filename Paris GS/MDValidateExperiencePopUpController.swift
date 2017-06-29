//
//  MDValidateExperiencePopUpController.swift
//  Paris GS
//
//  Created by Motion Displays on 07-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

protocol ValidateExperienceProtocol: class {
    
    func closePopUp()
    func saleMade()
    func sendedReason()
    
}

class MDValidateExperiencePopUpController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{

    weak var delegate : ValidateExperienceProtocol!
    @IBOutlet weak var imgThanks: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitleFirstPopUp: UILabel!
    @IBOutlet weak var tableViewFirstPopUp: UITableView!
    @IBOutlet weak var lbTitleSecondPopUp: UILabel!
    @IBOutlet weak var btValidate: UIButton!
    @IBOutlet weak var imgRadioOtherReason: UIImageView!
//    @IBOutlet weak var btYes: UIButton!
//    @IBOutlet weak var btNo: UIButton!
    @IBOutlet var cellOtherReason: UITableViewCell!
    @IBOutlet var viewPopUPQuestion: UIView!
    @IBOutlet var viewPopUpReason: UIView!
    @IBOutlet weak var tvOtherReason: KMPlaceholderTextView!
    
    var surveysManager: MDSurveysManager!
    var reasons = Array<MDReason>()
    var answer: Int!
    var comment: String!
    var option: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let width = UIScreen.main.bounds.size.width
        let heigth = UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.frame = CGRect(x:0, y:0, width:width, height:heigth)
        
        self.viewPopUPQuestion.frame = CGRect(x:width/2 - self.viewPopUPQuestion.frame.size.width/2 , y:heigth/2 - self.viewPopUPQuestion.frame.size.height/2, width:self.viewPopUPQuestion.frame.size.width, height:self.viewPopUPQuestion.frame.size.height)
        self.viewPopUpReason.frame = CGRect(x:width, y:heigth/2 - self.viewPopUpReason.frame.size.height/2, width:self.viewPopUpReason.frame.size.width, height:self.viewPopUpReason.frame.size.height)
        
//        btNo.layer.cornerRadius = kCornerRadiusButton
//        btNo.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
//        btNo.layer.borderWidth = 1.0
//        btYes.layer.cornerRadius = kCornerRadiusButton
        
        btValidate.layer.cornerRadius = kCornerRadiusButton
        
        tvOtherReason.layer.cornerRadius = kCornerRadiusButton
        tvOtherReason.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        tvOtherReason.layer.borderWidth = 1.0
        
        self.view.addSubview(viewPopUPQuestion)
        self.view.addSubview(viewPopUpReason)
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.register(UINib.init(nibName: "MDReasonCell", bundle: nil), forCellReuseIdentifier: "reasonCell")
        tableView.tag = 1
        
        tableViewFirstPopUp.tableFooterView = UIView.init(frame: CGRect.zero)
        tableViewFirstPopUp.register(UINib.init(nibName: "MDReasonCell", bundle: nil), forCellReuseIdentifier: "reasonCell")

        lbTitleFirstPopUp.text = surveysManager.title
    }
    
    
    func showSecondPopUp(index: Int)
    {
        lbTitleSecondPopUp.text = surveysManager.options[index].name
        reasons = surveysManager.options[index].reasons
        option = surveysManager.options[index].id
        tableView.reloadData()
        var newFrameFistPopUp = viewPopUPQuestion.frame;
        newFrameFistPopUp.origin.x = -self.view.frame.size.width;
        var newFrameSecondPopUp = viewPopUpReason.frame;
        newFrameSecondPopUp.origin.x = self.view.frame.size.width/2 - self.viewPopUpReason.frame.size.width/2;
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.viewPopUPQuestion.frame = newFrameFistPopUp
            self.viewPopUpReason.frame = newFrameSecondPopUp
        }) { (Bool) in
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 1)
        {
            return reasons.count + 1
        }
        else
        {
            return surveysManager.options.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if(indexPath.row == reasons.count && tableView.tag == 1)
        {
            return cellOtherReason
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath as IndexPath) as! MDReasonCell

        
        if(tableView.tag == 1)
        {
            cell.lbReason.text = reasons[indexPath.row].descriptionReason
        }
        else
        {
            cell.lbReason.text = surveysManager.options[indexPath.row].descriptionOption
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == reasons.count && tableView.tag == 1)
        {
            return cellOtherReason.frame.size.height
        }
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.tag == 1)
        {
            if(indexPath.row == reasons.count)
            {
                imgRadioOtherReason.image = UIImage.init(named:"bt_radiocheck_fill")
                tvOtherReason.isEditable = true
                tvOtherReason.becomeFirstResponder()
                answer = nil
                return
            }
            
            answer = reasons[indexPath.row].id
        }
        
        let currentCell = tableView.cellForRow(at: indexPath) as? MDReasonCell
        currentCell?.imgRadio.image = UIImage.init(named:"bt_radiocheck_fill")        
        
        if(tableView.tag != 1 && surveysManager.options[indexPath.row].type == "negative")
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                 self.showSecondPopUp(index: indexPath.row)
            }
           
        }
        else if(tableView.tag != 1)
        {
            surveysManager.setSurveysReviewPositive(surveyId: surveysManager.id, optionId: surveysManager.options[indexPath.row].id, hasError: { (error: Bool) in
                if(!error)
                {
                    self.dismiss(animated: true, completion: {
                        MDShoppingCartViewController.shoppingCart.deleteAllProduct()
                        self.delegate.saleMade()
                    })
                }
            })

        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(indexPath.row == reasons.count && tableView.tag == 1)
        {
            imgRadioOtherReason.image = UIImage.init(named:"bt_radiocheck")
            tvOtherReason.isEditable = false
            tvOtherReason.text = ""
            comment = nil
            return
        }

        let currentCell = tableView.cellForRow(at: indexPath) as? MDReasonCell
        currentCell?.imgRadio.image = UIImage.init(named:"bt_radiocheck")

    }

    func textViewDidBeginEditing(_ textView: UITextView) {
         self.animateTextField(textField: textView, up:true)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
         self.animateTextField(textField: textView, up:false)
         comment = tvOtherReason.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
         comment = tvOtherReason.text
    }
  
    
    /// Lifts or lowers the view so the keyboard doesn't cover the UITextField
    /// - Parameters:
    ///   - textField: UITextField that you doesn't want the keyboard cover
    ///   - up: Boolean to indicate if lifts or lowers the view
    func animateTextField(textField: UITextView, up: Bool) {
        let movementDistance:CGFloat = -(cellOtherReason.frame.origin.y)
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


    @IBAction func closePopUPReason(_ sender: Any) {
        self.dismiss(animated: true, completion: {
             self.delegate.closePopUp()
        })
    }

    @IBAction func closePopUp(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate.closePopUp()
        })
    }
    


    @IBAction func sendReason(_ sender: Any) {
        if(answer != nil)
        {
            surveysManager.setSurveysReviewNegative(surveyId: surveysManager.id, optionId: option, reasonId: answer, hasError: { (error:Bool) in
                if(!error)
                {
                    self.dismiss(animated: true, completion: {
                        self.delegate.sendedReason()
                    })
                }
           })

        }
        else if(comment != nil && comment != "")
        {
            surveysManager.setSurveysReviewNegative(withCommnet: comment, surveyId: surveysManager.id, optionId: option, hasError: { (error:Bool) in
                
                if(!error)
                {
                    self.dismiss(animated: true, completion: {
                        self.delegate.sendedReason()
                    })
                }
                
           })
        }
        else
        {
            let alertController = UIAlertController.init(title: "", message:"Debe seleccionar una razón.", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
