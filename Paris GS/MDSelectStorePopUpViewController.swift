//
//  MDSelectStorePopUpViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 13-10-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSelectStorePopUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet var viewPopUp: UIView!
    @IBOutlet weak var btVincular: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var indexSelected = 0
    let userDefault = UserDefaults.standard
    var options: Array<AnyObject>!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
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
       // btVincular.isEnabled = false
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        btVincular.isEnabled = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - TableView DataSoure
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MDSession.listStores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let MyIdentifier = "MyIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if(cell == nil)
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: MyIdentifier)
        }
        cell?.accessoryType = .none
        cell?.textLabel?.text = MDSession.listStores[indexPath.row].name
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
    
        self.userDefault.set(MDSession.listStores[self.indexSelected].salesCode, forKey: "store")
        self.userDefault.synchronize()
        
        MDSession.sales_code = MDSession.listStores[self.indexSelected].salesCode
        
        MDSession.listStores = Array<MDStore>()

                self.dismiss(animated: false, completion: {
                    
                    if(MDSession.listDevices.count > 0)
                    {
                        let linkUpPopUp = MDLinkUpViewController()
                        linkUpPopUp.modalPresentationStyle = .overCurrentContext
                        linkUpPopUp.modalTransitionStyle = .crossDissolve
                        self.appDelegate.navigationController.visibleViewController?.present(linkUpPopUp, animated: true, completion: nil)
                        
                    }
                    else
                    {
                        self.appDelegate.navigationController?.pushViewController                        (MDWelcomeViewController(), animated: true)
                    }

                })

    }
    
    deinit {
        print("viewcontroller is being deallocated")
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
