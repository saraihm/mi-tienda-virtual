//
//  MDSettingsViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 06-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

     var userDefault = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UITableViewCell.appearance().tintColor = COLOR_BLUE
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "MyIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if(cell == nil)
        {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: MyIdentifier)
        }
        
        cell?.textLabel?.font = UIFont.init(name: "paris-Regular", size: 24)
        cell?.textLabel?.textColor = COLOR_GRAY_DARK
        cell?.detailTextLabel?.font = UIFont.init(name: "paris-Regular", size: 18)
        cell?.detailTextLabel?.textColor = COLOR_GRAY
        cell?.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Producción"
            cell?.detailTextLabel?.text = MDTools.kWSURLProduction
            
        default:
            cell?.textLabel?.text = "Test"
            cell?.detailTextLabel?.text = MDTools.kWSURLTest
        }
        
        if(userDefault.value(forKey: kKeyBaseUrl) as? String == cell?.detailTextLabel?.text)
        {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell?.accessoryType = .checkmark
        }
        else
        {
            cell?.accessoryType = .none
        }
        
        cell?.tintColor = COLOR_BLUE

        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let alertController = UIAlertController.init(title: "Cambiar configuración", message:"Para cambiar la configuración por favor ingrese la contraseña:", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            self.view.endEditing(true)
 
            if(alertController.textFields![0].text! == "123tlb")
            {
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
                cell?.accessoryView?.tintColor = COLOR_BLUE
                
                switch indexPath.row {
                case 0:
                    self.userDefault.set(MDTools.kWSURLProduction, forKey: kKeyBaseUrl)
                    
                default:
                    self.userDefault.set(MDTools.kWSURLTest, forKey: kKeyBaseUrl)
                }
                
                self.userDefault.synchronize()
                MotionDisplaysApi.refreshBaseUrl()
                
                tableView.reloadData()

            }
          
            
        })
        
        let cancel = UIAlertAction.init(title: "Cancelar", style: .cancel, handler:  { (action: UIAlertAction) in
            self.view.endEditing(true)
        })
        
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Contraseña"
            textField.keyboardType = .emailAddress
            textField.isSecureTextEntry = true
            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.actions[0].isEnabled = false
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func textChanged(sender:AnyObject) {
        let tf = sender as! UITextField
        // enable OK button only if there is text
        // hold my beer and watch this: how to get a reference to the alert
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = (tf.text != "")
    }
    

    @IBAction func goBack(_ sender: Any) {
        
       _ = self.navigationController?.popViewController(animated: true)
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
