//
//  MDCategoriesMenuViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 26-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDCategoriesMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var categories = MDCategoriesManager.categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView DataSoure
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let MyIdentifier = "MyIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if(cell == nil)
        {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: MyIdentifier)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = categories[indexPath.row].itemName
        cell?.textLabel?.textColor = COLOR_BLUE_DARK

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         MotionDisplaysApi.cancelAllRequests()
        let loading = MDLoadingView.init(frame: self.view.bounds)
        loading.starLoding(inView: self.view)
        
        if(MDCategoriesManager.categories[indexPath.row].hasNext)
        {
            FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                kFIRParameterContentType: "Seleccionar categoria" as NSObject,
                kFIRParameterItemID: MDCategoriesManager.categories[indexPath.row].itemName as NSObject
                ])
            
            let categoriesManager = MDCategoriesManager()
            categoriesManager.getSubcategories(uniqueID: MDCategoriesManager.categories[indexPath.row].uniqueID, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    let viewController = MDSubcategoriesViewController()
                    viewController.subcategories = categoriesManager.subCategories
                    viewController.descriptionString = categoriesManager.appSubTitle
                    viewController.titleName = MDCategoriesManager.categories[indexPath.row].itemName
                    viewController.type = categoriesManager.type
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.navigationController.dismiss(animated: false, completion: {
                        appDelegate.navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDCategoriesViewController())
                        appDelegate.window?.rootViewController = appDelegate.navigationController
                        appDelegate.navigationController.pushViewController(viewController, animated: false)
                    })
            
//                    let transition = CATransition()
//                    transition.duration = 0.5
//                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                    transition.type = kCATransitionPush
                  //  appDelegate.navigationController.view.layer.add(transition, forKey: nil)
                                       self.dismiss(animated: false, completion: nil)
                    appDelegate.sendInstructionToParisTV(instruction: ["action": "goToSubCategoryRoot" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject, "image": MDCategoriesManager.categories[indexPath.row].imageBodyPortrait as AnyObject, "title": MDCategoriesManager.categories[indexPath.row].itemName as AnyObject, "subtitle": categoriesManager.tvTitle as AnyObject])

                }
                
                loading.stopLoding()
            })
        }
        else
        {
            let filters = MDFilterManager()
            MDFilterMenuViewController.filters = filters
            MDSubcategoriesViewController.categoryId = MDCategoriesManager.categories[indexPath.row].uniqueID
            filters.getFiltersWith( categoryId: MDSubcategoriesViewController.categoryId!, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    MDFilterMenuViewController.filters.filterWithProductsId = false
                    self.navigationController?.pushViewController(MDProductsViewController(), animated: true)
                }
                
                loading.stopLoding()
            })
            
        }

      
    }
    
    deinit {
        print("MDCategoriesMenu is being deallocated")
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
