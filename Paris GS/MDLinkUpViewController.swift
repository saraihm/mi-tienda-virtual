//
//  MDLinkUpViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 13-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDLinkUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet var viewPopUp: UIView!
    @IBOutlet weak var btVincular: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var indexSelected = 0
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.size.width
        let heigth = UIScreen.main.bounds.size.height
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.frame = CGRect(x:0, y:0, width:width, height:heigth)
        self.viewPopUp.frame = CGRect(x:width/4, y:heigth/4, width:width/2, height:heigth/2)
        self.view.addSubview(viewPopUp)

        // Do any additional setup after loading the view.
        btVincular.layer.cornerRadius = kCornerRadiusButton
        btVincular.isEnabled = false
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - TableView DataSoure
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MDSession.listDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let MyIdentifier = "MyIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if(cell == nil)
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: MyIdentifier)
        }
        
        cell?.accessoryType = .none
        cell?.textLabel?.text = MDSession.listDevices[indexPath.row].name
        cell?.textLabel?.textColor = COLOR_BLUE_DARK
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath)
        currentCell?.accessoryType = .checkmark
        indexSelected = indexPath.row
        btVincular.isEnabled = true
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let lastCell = tableView.cellForRow(at: indexPath as IndexPath)
        lastCell?.accessoryType = .none
    }

    @IBAction func linkUp(_ sender: AnyObject) {
        MDSession.linkDevice(deviceID: MDSession.listDevices[indexSelected].id) { (hasError: Bool) in
            if(!hasError)
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
                if(appDelegate.client.connections.count > 0)
                {

                    for server in appDelegate.client.services.allObjects {

                        var serv = server as! NetService
                        print(serv.name)
                        
                        if(serv.name == MDSession.listDevices[self.indexSelected].uuid)
                        {
                 
                            self.userDefault.set(MDSession.listDevices[self.indexSelected].uuid, forKey: "linked_tv")
                            self.userDefault.synchronize()
                            MDSession.UUIDAppleTV = MDSession.listDevices[self.indexSelected].uuid
                            print(MDSession.UUIDAppleTV)
                            
                            appDelegate.sendInstructionToParisTV(instruction: ["action": "linked" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page":"" as AnyObject])
                            appDelegate.navigationController.pushViewController(MDWelcomeViewController(), animated: true)
                            MDSession.listDevices = Array<MDDevice>()
                            self.dismiss(animated: false, completion: nil)
                            
                            return
                        }
                    }
                    
                    let alertController = UIAlertController.init(title: "Error", message:"No se ha podido establecer conexión con el Apple TV, por favor intenta de nuevo", preferredStyle: .alert)
                    
                    let aceptar = UIAlertAction.init(title: "Aceptar", style: .cancel, handler: { (action: UIAlertAction) in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(aceptar)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else
                {
                    let alertController = UIAlertController.init(title: "Error", message:"No se ha podido establecer conexión con el Apple TV, por favor intenta de nuevo", preferredStyle: .alert)
                    
                    let aceptar = UIAlertAction.init(title: "Aceptar", style: .cancel, handler: { (action: UIAlertAction) in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(aceptar)
                    self.present(alertController, animated: true, completion: nil)
                }
                
               
            }
        }
        
    }

    @IBAction func closePopUp(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navigationController.pushViewController(MDWelcomeViewController(), animated: true)
        MDSession.listDevices = Array<MDDevice>()
        self.dismiss(animated: false, completion: nil)
    }
    
    deinit {
       print("viewcontroller is being deallocated")
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
