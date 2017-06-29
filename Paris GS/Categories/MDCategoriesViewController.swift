//
//  MDCategoryViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class MDCategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ENSideMenuDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imageBlur: UIImageView?;
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var searchResult = Array<MDSearch>()
    var appDelegate: AppDelegate!
    var autocompleteTableView: UITableView!
    var loading: MDLoadingView!
    
    
    //Variables obtained from another ViewController
    var descriptionString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.addLogoToNavegationItem(viewController: self)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)
        self.navigationItem.hidesBackButton = true
        
        self.sideMenuController()?.sideMenu?.bouncingEnabled = false
        collectionView!.register(UINib(nibName: "MDCategoryCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        collectionView.isPagingEnabled = true
        
        if(MDCategoriesManager.categories.count <= 3)
        {
            pageControl.isHidden = true
        }
    
        pageControl.numberOfPages = MDCategoriesManager.categories.count/3
        pageControl.currentPage = 0
        
        if(descriptionString != nil)
        {
            lbDescription.text = descriptionString.uppercased()
        }
      
        // Config search product
        searchBar = UISearchBar.init()
        searchBar.placeholder = "Buscar por palabra clave"
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundImage = UIImage()
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.self) {
                    let textField: UITextField = subview as! UITextField
                    textField.backgroundColor = UIColor.white
                    textField.font = UIFont.init(name: "OpenSans", size: 14)
                    textField.textColor = COLOR_GRAY_DARK
                    textField.tintColor = COLOR_GRAY_DARK
                }
            }
        }
        
        tableView = UITableView.init(frame: CGRect(x:0, y:100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100))
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.isHidden = true
        
        // Config Paris tvOS
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        autocompleteTableView = UITableView.init(frame: CGRect(x: 0, y: 100, width: 320, height: 120))
        autocompleteTableView.delegate = self;
        autocompleteTableView.dataSource = self;
        autocompleteTableView.isScrollEnabled = true;
        autocompleteTableView.isHidden = true;
        self.view.addSubview(autocompleteTableView)


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.navigationItem.title = ""
        if(imageBlur != nil)
        {
            self.hideSideMenuView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)
        self.sideMenuController()?.sideMenu?.delegate = self
         NotificationCenter.default.addObserver(self, selector: #selector(self.continueShopping), name:NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueToPay), name:NSNotification.Name(rawValue: "NotificationPay"), object: nil)
           loading = MDLoadingView.init(frame: self.view.bounds)

    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
             MotionDisplaysApi.cancelAllRequests()
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        let alertController = UIAlertController.init(title: "Advertencia", message:"Receive memory warning", preferredStyle: .alert)
        
        let aceptar = UIAlertAction.init(title: "Aceptar", style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(aceptar)
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - ScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
    }

    
    // MARK: – UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MDCategoriesManager.categories.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath as IndexPath) as! MDCategoryCell
        
        cell.titleCategory.text = (MDCategoriesManager.categories[indexPath.row].itemName).uppercased()
        if(MDCategoriesManager.categories[indexPath.row].imageHomePortrait != nil)
        {
            let image = MDCategoriesManager.categories[indexPath.row].imageHomePortrait
            cell.imgCategory.sd_setImage(with: URL.init(string: image!))  
        }
        return cell
    }
    
    // MARK: – UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        loading.starLoding(inView: self.view)
        
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Seleccionar categoria" as NSObject,
            kFIRParameterItemID: MDCategoriesManager.categories[indexPath.row].itemName as NSObject
            ])
        
        if(MDCategoriesManager.categories[indexPath.row].hasNext)
        {
            
            let categoriesManager = MDCategoriesManager()
            categoriesManager.getSubcategories(uniqueID: MDCategoriesManager.categories[indexPath.row].uniqueID, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    let viewController = MDSubcategoriesViewController()
                    viewController.subcategories = categoriesManager.subCategories
                    viewController.descriptionString = categoriesManager.appSubTitle
                    viewController.titleName = MDCategoriesManager.categories[indexPath.row].itemName
                    viewController.type = categoriesManager.type
                    self.navigationController?.pushViewController(viewController, animated: true)
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "continueToSubCategories" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "Categories" as AnyObject, "image": MDCategoriesManager.categories[indexPath.row].imageBodyPortrait as AnyObject, "title": MDCategoriesManager.categories[indexPath.row].itemName as AnyObject, "subtitle": categoriesManager.tvTitle as AnyObject])
                }
                
                self.loading.stopLoding()
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
                
                self.loading.stopLoding()
            })

        }
    }
    
    // MARK: – UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:self.collectionView.frame.size.width/3-1, height: self.collectionView.frame.size.height-1);

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 1, 0);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
    
    //MARK: TableView DataSource
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if( searchResult.count > 1)
        {
            return 1
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let MyIdentifier = "MyIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if(cell == nil)
        {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: MyIdentifier)
            
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.textColor = COLOR_GRAY_DARK
        cell?.textLabel?.font = UIFont.init(name: "OpenSans", size: 20)
        cell?.textLabel?.text = searchResult[indexPath.row].title
        cell?.detailTextLabel?.font = UIFont.init(name: "OpenSans", size: 18)
        cell?.detailTextLabel?.text = "(" + String(searchResult[indexPath.row].resultsCount) + ") "
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none

        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewHeader = UIView.init()
        let label = UILabel.init(frame: CGRect(x:170, y:0, width:self.tableView.frame.size.width, height:50))
        label.textColor = COLOR_BLUE_LIGHT
        label.text = "TOTAL"
        label.font = UIFont.init(name: "AzoSans-Medium", size: 22)
        viewHeader.addSubview(label)
        return viewHeader
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productsId = searchResult[indexPath.row].productsId
        if(productsId.count > 0)
        {
            searchBar.endEditing(true)
            loading.starLoding(inView: self.view)
            MDFilterMenuViewController.filters = MDFilterManager()
            MDFilterMenuViewController.filters.getFiltersWith(productsID: productsId, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    let viewController = MDProductsViewController()
                    viewController.productsIds = productsId
                    viewController.titleName = self.searchResult[indexPath.row].title
                    viewController.subTitleName = self.searchResult[indexPath.row].subTitle
                    viewController.isSearch = true
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDCategoriesViewController())
                    MDFilterMenuViewController.filters.filterWithProductsId = true
                    MDFilterMenuViewController.productsId = productsId
                    
                    appDelegate.window?.rootViewController = appDelegate.navigationController
                    appDelegate.navigationController.pushViewController(viewController, animated: false)
                    self.hideSearchBar()

                }
                
                self.loading.stopLoding()

            })

        }
    }
    
    
    // MARK: - SearchBar
    func showSearchBar()
    {
        self.navigationItem.addSearchBar(searchBar: searchBar, viewController: self)
        if(imageBlur == nil)
        {
            imageBlur = UIImageView.init(image: UIImage().imageFromView(view: self.view))
        }
        imageBlur!.image = imageBlur!.image?.applyLightEffect()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.hideSideMenuView))
        imageBlur?.isUserInteractionEnabled = true
        imageBlur?.addGestureRecognizer(tapGesture)
        self.view.addSubview(imageBlur!)
        self.view.addSubview(tableView)
    }
    
    func cancelSearchButton()
    {
        MotionDisplaysApi.cancelAllRequests()
        loading.stopLoding()
        hideSearchBar()
    }
    
    func hideSearchBar()
    {
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)
        tableView.removeFromSuperview()
        imageBlur!.removeFromSuperview()
        imageBlur = nil
        
    }
    
    // MARK: - SearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Buscar" as NSObject,
            kFIRParameterItemID: searchBar.text! as NSObject
            ])
        searchBar.endEditing(true)
        loading.starLoding(inView: self.view)
        let searchProduct = MDSearchManager()
        searchProduct.searchProduct(key: searchBar.text!, hasError: { (hasError: Bool) in
            if(hasError == false)
            {
                self.searchResult = searchProduct.resultSkus
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            
            self.loading.stopLoding()
            
        })
    }
    
    
    //MARK: - Notification
    func continueShopping() {
        self.hideSideMenuView()
    }
    
    func continueToPay() {
        let loginSeller = MDLoginSellerPopUpViewController()
        loginSeller.modalPresentationStyle = .overCurrentContext
        loginSeller.modalTransitionStyle = .crossDissolve
        self.present(loginSeller, animated: true, completion: nil)
    }

    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
        imageBlur = UIImageView.init(image: UIImage().imageFromView(view: self.view))
        imageBlur!.image = imageBlur!.image?.applyLightEffect()
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.hideSideMenuView))
        imageBlur?.isUserInteractionEnabled = true
        imageBlur?.addGestureRecognizer(tapGesture)
        self.view.addSubview(imageBlur!)
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
        if(imageBlur != nil)
        {
            imageBlur!.removeFromSuperview()
            imageBlur = nil
        }
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)

    }

    
    deinit {
        print("MDCategoriesViewController is being deallocated")
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
