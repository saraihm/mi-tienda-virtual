//
//  MDProductsViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 26-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ENSideMenuDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FilterMenunDelegate {
    
    @IBOutlet weak var btCloseOnBoard: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollViewOnBoard: UIScrollView!
    @IBOutlet weak var lbSubTitle: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var viewCompareProducts: UIView!
    
    var imageBlur: UIImageView?
    var imageBlurCompare: UIImage?
    
    var productManager = MDProductManager()
    var products = Array<MDProduct>()
    
    var searchBar: UISearchBar!
    var searchResult = Array<MDSearch>()
    var tableView: UITableView!
    
    var compareProducts: Int!
    var productsToCompare: Array<MDProduct>!
    var indexProductsToCompare = Array<Int>()
    
    var loadMoreProducts: Bool!
    var limitProductsShow: Int!
    var productShow: Int!
    var indexProductShown: Int!
    
    let userDefault = UserDefaults.standard
    var loading: MDLoadingView!
    var isBack = false
  
    //tvOS
    var lastIndex: Int!
    var appDelegate: AppDelegate!
       
    //Variables obtained from another ViewController
    var productsIds = Array<Int>()
    var titleName: String!
    var subTitleName: String!
    static var isComeFromProductDetails = false
    var isShowOnBoard = false
    var isFilter = false
    var isSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backItem?.title = ""
        // Do any additional setup after loading the view.
        self.navigationItem.addLogoToNavegationItem(viewController: self)
        self.navigationItem.addCategoriesToNavegationItem(viewController: self)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: true, viewController: self)
        self.sideMenuController()?.sideMenu?.bouncingEnabled = false
        
        lbTitle.text = titleName.uppercased()
        lbSubTitle.text = subTitleName.uppercased()
        
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

        tableView = UITableView.init(frame: CGRect(x:0, y:100, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height - 100))
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        self.tableView.isHidden = true
        
        // Config compare products
        viewCompareProducts.frame = CGRect(x:0, y:UIScreen.main.bounds.height, width:UIScreen.main.bounds.width, height:self.viewCompareProducts.frame.size.height)
        view.addSubview(viewCompareProducts)
        
        // Config results products
        collectionView!.register(UINib(nibName: "MDProductCell", bundle: nil), forCellWithReuseIdentifier: "productCell")
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = true
        
        productManager.products.removeAll()
        compareProducts = 0
        lastIndex = 0
        searchResult = Array<MDSearch>()
        loadMoreProducts = true
        limitProductsShow = 8
        productShow = 7
        productsToCompare = Array<MDProduct>()
        indexProductsToCompare = Array<Int>()
        products.removeAll()

        loading = MDLoadingView.init(frame: UIScreen.main.bounds)

        if(productsIds.count == 0)
        {
            productsIds = (MDFilterMenuViewController.filters.productIds)
            self.loadProducts(offset: 0, limit: limitProductsShow)
        }
        else
        {
            self.loadProducts(offset: 0, limit: limitProductsShow)
        }
        
        MDFilterMenuViewController.delegate = self
        
        // Config Paris tvOS
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendInstructionToParisTV(instruction: ["action": "" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
        
        self.scrollViewOnBoard.isPagingEnabled = true
        self.scrollViewOnBoard.tag = 5
        self.scrollViewOnBoard.delegate = self
        self.scrollViewOnBoard.showsHorizontalScrollIndicator = false
        self.scrollViewOnBoard.bounces = false
        
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
      
        btCloseOnBoard.layer.cornerRadius = kCornerRadiusButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        isFilter = false
        self.navigationItem.title = ""
        if(imageBlur != nil)
        {
            self.hideSideMenuView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: true, viewController: self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueShopping), name:NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.markCellFromParisTvNotification(notification:)), name:NSNotification.Name(rawValue: "NotificationIdentifier"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueToPay), name:NSNotification.Name(rawValue: "NotificationPay"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.back), name:NSNotification.Name(rawValue: "NotificationError"), object: nil)
        
        self.sideMenuController()?.sideMenu?.delegate = self
        if(indexProductShown != nil)
        {
            MDProductsViewController.isComeFromProductDetails = false
            
            loading.starLoding(inView: self.view)
            
            productManager.getProductsFromIDs(productIds: [products[indexProductShown].id], hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    self.products = self.productManager.products
                    self.collectionView.reloadItems(at: [IndexPath.init(row: self.indexProductShown, section: 0)])
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updateProduct" as AnyObject, "data": self.productManager.data as AnyObject, "index": self.indexProductShown as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
                    self.indexProductShown = nil

                }
                
                if(self.loading != nil)
                {
                    self.loading.stopLoding()
                }
                
            })
        
        }
    }
    
    func back(){
        _ = self.navigationController?.popViewController(animated: true)
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

    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            isBack = true
            MotionDisplaysApi.cancelAllRequests()
            isFilter = false
            if(isSearch)
            {
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "goToHome" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
            }
            else
            {
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
            }
          
        }
    }
    
    
    // MARK: - LoadProducts
    
    /// Loads products from a specified range
    /// - Parameters:
    ///   - offset: start of range
    ///   - limit: end of range
    func loadProducts(offset: Int, limit: Int) {
        
        if(productsIds.count == products.count )
        {
            loadMoreProducts = false
            return
        }
        
        loading.starLoding(inView: self.view)
        
        let arrayProductsIDs = MDTools.subArray(array: productsIds, range: NSMakeRange(offset, limit))
    
        productManager.getProductsFromIDs(productIds: arrayProductsIDs, hasError: { (hasError: Bool) in
            if(hasError == false)
            {
                self.products = self.productManager.products
                self.collectionView.reloadData()
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "loadProducts" as AnyObject, "products": self.productManager.data as AnyObject, "limit": limit as AnyObject, "offset": offset as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
                
                if(self.userDefault.bool(forKey: "showOnBoard"))
                {
                    self.isShowOnBoard = true
                    if(self.productsIds.count == 2)
                    {
                        self.setImageToScrollview(images: ["onboard1-1","onboard2-1","onboard3-1" ])
                    }
                    else if (self.productsIds.count == 3)
                    {
                        self.setImageToScrollview(images: ["onboard1-2","onboard2-2","onboard3-2" ])
                    }
                    else if (self.productsIds.count >= 4)
                    {
                        self.setImageToScrollview(images: ["onboard1","onboard2","onboard3" ])
                    }
                    else
                    {
                        self.setImageToScrollview(images: ["onboard1-3","onboard2-3" ])
                        self.pageControl.numberOfPages = 2
                    }
                    
                    self.userDefault.set(false, forKey: "showOnBoard")
                    self.userDefault.synchronize()
                    self.scrollViewOnBoard.isHidden = false
                    self.pageControl.isHidden = false
                    self.btCloseOnBoard.isHidden = false
                }

            }
            
            self.loading.stopLoding()
            
        })
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.tag == 5)
        {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            if(pageControl.currentPage == pageControl.numberOfPages-1 && Int(pageNumber) == pageControl.numberOfPages-1)
            {
                scrollViewOnBoard.removeFromSuperview()
                pageControl.removeFromSuperview()
                btCloseOnBoard.removeFromSuperview()
                isShowOnBoard = false
                return
            }
            
            pageControl.currentPage = Int(pageNumber)
        }
        else
        {
            let pageNumber = round(collectionView.contentOffset.y / collectionView.frame.size.height)
            
            print(Int(pageNumber))
            let indexPaths = collectionView.indexPathsForVisibleItems
            let indexPathsSort = indexPaths.sorted()
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "indexCollectionView" as AnyObject, "firstProductIndexShow":  indexPathsSort[0].row as AnyObject, "lastProductIndexShow": collectionView.indexPathsForVisibleItems.count as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])

        }
    }
    
    // MARK: – OnBoard
    
    /// Adds UIImageViews side by side into a UIScrollView to create a gallery of images
    /// - Parameter images: Array<String> with the name of the images
    func setImageToScrollview(images: Array<String>) {
        scrollViewOnBoard.contentSize = CGSize(width:self.view.frame.width * CGFloat.init(images.count), height: self.view.frame.height-65)
        
            for index in 0...images.count-1 {
                let imageView = UIImageView.init(frame: CGRect(x:self.view.frame.width * CGFloat.init(index), y:0, width:self.view.frame.width, height:scrollViewOnBoard.frame.height))
                imageView.image = UIImage.init(named: images[index])
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.changePage)))
                scrollViewOnBoard.addSubview(imageView)
            }
    }

    func changePage() -> () {
        if(pageControl.currentPage < pageControl.numberOfPages-1)
        {
            pageControl.currentPage = pageControl.currentPage+1
            let x = CGFloat(pageControl.currentPage) * scrollViewOnBoard.frame.size.width
            scrollViewOnBoard.decelerationRate = 2.0
            scrollViewOnBoard.setContentOffset(CGPoint(x:x, y:0), animated: true)

        }
        else
        {
            scrollViewOnBoard.removeFromSuperview()
            pageControl.removeFromSuperview()
            btCloseOnBoard.removeFromSuperview()
            isShowOnBoard = false
        }
    }

   
    // MARK: – UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
      //  return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath as IndexPath) as! MDProductCell
     
        if(products.count == 3)
        {
            cell.imgLeftConstraint.constant = 40
            cell.imgRightConstraint.constant = 40
            cell.imgTopConstraint.constant = 45
            cell.descriptionLeftConstraint.constant = 30
            cell.descriptionRightConstraint.constant = 30
            cell.descriptionTopConstraint.constant = 25
            cell.lbDescription.font = UIFont.init(name: "OpenSans", size: 16)
            cell.lbPrice.font = UIFont.init(name: "AzoSans-Bold", size: 45)
            cell.lbNormalPrice.font = UIFont.init(name: "OpenSans", size: 16)
            cell.lbDiscount.font = UIFont.init(name: "OpenSans", size: 13)
            cell.btCompareBottomConstraint.constant = 100
       }
       else if(products.count == 2)
       {
            cell.imgLeftConstraint.constant = 100
            cell.imgRightConstraint.constant = 100
            cell.imgTopConstraint.constant = 25
            cell.descriptionLeftConstraint.constant = 80
            cell.descriptionRightConstraint.constant = 80
            cell.descriptionTopConstraint.constant = 25
            cell.lbDescription.font = UIFont.init(name: "OpenSans", size: 18)
            cell.lbPrice.font = UIFont.init(name: "AzoSans-Bold", size: 50)
            cell.lbNormalPrice.font = UIFont.init(name: "OpenSans", size: 18)
            cell.lbDiscount.font = UIFont.init(name: "OpenSans", size: 16)
            cell.btCompareBottomConstraint.constant = 80

       }
        else
        {
            cell.imgLeftConstraint.constant = 48
            cell.imgRightConstraint.constant = 48
            cell.imgTopConstraint.constant = 10
            cell.descriptionLeftConstraint.constant = 30
            cell.descriptionRightConstraint.constant = 30
            cell.descriptionTopConstraint.constant = 5
            cell.lbDescription.font = UIFont.init(name: "OpenSans", size: 15)
            cell.lbPrice.font = UIFont.init(name: "AzoSans-Bold", size: 30)
            cell.lbNormalPrice.font = UIFont.init(name: "OpenSans", size: 14)
            cell.lbDiscount.font = UIFont.init(name: "OpenSans", size: 13)
            cell.btCompareBottomConstraint.constant = 5
            
        }
    
        cell.layoutSubviews()
        cell.layoutIfNeeded()
        cell.imgHeightConstraint.constant = cell.imgProduct.frame.size.width
        if(products[indexPath.row].image != nil){
            let image =  products[indexPath.row].image!
            cell.imgProduct.sd_setImage(with: URL.init(string: image), placeholderImage: UIImage.init(named: "cargando"))
        }
        else
        {
            cell.imgProduct.image = UIImage.init(named: "no_disponible")
        }
        
        MDTools.rounderBorderImage(imageView: cell.imgProduct)
        cell.lbDescription.text = products[indexPath.row].name
        cell.btCompare.tag = 1
        if(indexProductsToCompare.count > 0)
        {
            for index: Int in indexProductsToCompare {
                
                if(index == indexPath.row)
                {
                    cell.btCompare.image = UIImage.init(named: "bt_comparar_lleno")
                    cell.btCompare.accessibilityIdentifier = "selected"
                    break
                }
                else
                {
                    cell.btCompare.image = UIImage.init(named: "bt_comparar_vacio")
                    cell.btCompare.accessibilityIdentifier = "deselected"
                }
            }
        }
        else
        {
            cell.btCompare.image = UIImage.init(named: "bt_comparar_vacio")
            cell.btCompare.accessibilityIdentifier = "deselected"
        }
       
        cell.btCompare.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.compareButtonSelection(sender:))))
        
        if(products[indexPath.row].discount != nil && products[indexPath.row].discount != "" && products[indexPath.row].discount != "-")
        {
            cell.lbDiscount.text = products[indexPath.row].discount
            cell.viewDiscount.isHidden = false
        }
        else
        {
            cell.viewDiscount.isHidden = true
        }
       
        let (bestPrice, normalPrice, _, isCencosud) = MDTools.price(prices: products[indexPath.row].prices)
        
        cell.lbPrice.text = bestPrice.value
        if(normalPrice != nil)
        {
            cell.lbNormalPrice.text = (normalPrice?.name)! + " " + (normalPrice?.value)!
        }
        else
        {
            cell.lbNormalPrice.text = ""
        }
        
        cell.imgTarjetaCencosud.isHidden = !isCencosud

        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 0
        cell.contentView.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(loadMoreProducts == true)
        {
            print(productShow, indexPath.row)
            if(productShow == indexPath.row)
            {
                productShow = indexPath.row + limitProductsShow
                print(indexPath.row , productShow)
                self.loadProducts(offset: indexPath.row+1, limit: productShow+1)
            }
        }
    }
    
    // MARK: – UICollectionViewDelegate
    
    func collectionView(_ didSelectItemAtcollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let productDetailsManager = MDProductDetailsManager()
        loading.starLoding(inView: self.view)
        var productClass = 0
        indexProductShown = indexPath.row
        
        if(MDSubcategoriesViewController.categoryId != nil)
        {
            productClass = MDSubcategoriesViewController.categoryId as! Int
        }
       
        productDetailsManager.getProductDetails(productId: products[indexPath.row].id, productClass: Int(productClass)) { (hasError: Bool) in
            
            if(hasError == false)
            {
                FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                    kFIRParameterContentType: "Producto visto" as NSObject,
                    kFIRParameterItemID: self.products[indexPath.row].sku as NSObject
                    ])
                
                 self.appDelegate.sendInstructionToParisTV(instruction: ["action": "productDetails" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject, "index": indexPath.row as AnyObject])
                
                productDetailsManager.SectionFichaProducto = 0
                
                if(productDetailsManager.productPresentation.longDescription == nil)
                {
                   productDetailsManager.numberOfSections = 1
                }
                else
                {
                    productDetailsManager.SectionDescription = 1
                    productDetailsManager.numberOfSections = 2
                }
                
                let variantManager = MDVariantManager.init(variants: productDetailsManager.productVariations)
                
                let viewController = MDProductDetailViewController()
                viewController.productDetailsManager = productDetailsManager
                viewController.product = self.products[indexPath.row].copyProduct()
                viewController.variantManager = variantManager
                self.navigationController?.pushViewController(viewController, animated: false)
                UIView.transition(with: (self.navigationController?.view)!, duration: 1, options: .transitionFlipFromRight, animations: nil, completion: nil)
               
            }
            self.loading.stopLoding()
           
        }

    }
    
    // MARK: – UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var retval = CGSize(width:self.collectionView.frame.size.width/4-1, height:self.collectionView.frame.size.height/2-1);
        
        if(products.count == 3)
        {
            retval = CGSize(width:self.collectionView.frame.size.width/3-1, height:self.collectionView.frame.size.height-1);
        }
        else if(products.count == 2)
        {
            retval = CGSize(width:self.collectionView.frame.size.width/2-1, height:self.collectionView.frame.size.height-1);
        }
     /*   else if(products.count == 1)
        {
            retval = CGSizeMake(self.collectionView.frame.size.width-1, self.collectionView.frame.size.height-1);
        }*/
        
        return retval
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 1, 1, 0);
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
        productsIds = searchResult[indexPath.row].productsId
        if(productsIds.count > 0)
        {
            searchBar.endEditing(true)
            loading.starLoding(inView: self.view)
            MDFilterMenuViewController.filters = MDFilterManager()
            MDFilterMenuViewController.filters.getFiltersWith(productsID: productsIds, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    let viewController = MDProductsViewController()
                    viewController.productsIds = self.productsIds
                    viewController.titleName = self.searchResult[indexPath.row].title
                    viewController.subTitleName = self.searchResult[indexPath.row].subTitle
                    viewController.isSearch = true
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDCategoriesViewController())
                    
                    MDFilterMenuViewController.filters.filterWithProductsId = true
                    MDFilterMenuViewController.productsId = self.productsIds
                    
                    appDelegate.window?.rootViewController = appDelegate.navigationController
                    appDelegate.navigationController.pushViewController(viewController, animated: false)
                     self.appDelegate.sendInstructionToParisTV(instruction: ["action": "removeProducts" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
                    self.hideSearchBar()
                }
                
                self.loading.stopLoding()
            })
            
        }

    }
    
    
     //MARK: Compare Products
    
    func compareButtonSelection(sender: UITapGestureRecognizer)
    {
        let btCompare = sender.view?.viewWithTag(1) as! UIImageView
        if(btCompare.accessibilityIdentifier == "deselected")
        {
            if(compareProducts < 2)
            {
                btCompare.image = UIImage.init(named: "bt_comparar_lleno")
                btCompare.accessibilityIdentifier = "selected"
                compareProducts = compareProducts + 1
                productsToCompare.append(products[(btCompare.superview?.tag)!])
                indexProductsToCompare.append((btCompare.superview?.tag)!)
            }
            if(compareProducts == 2)
            {
                viewCompareProducts.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showViewCompareProduct)))
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.viewCompareProducts.frame = CGRect(x:0, y:self.view.frame.size.height - self.viewCompareProducts.frame.size.height, width:self.viewCompareProducts.frame.size.width, height:self.viewCompareProducts.frame.size.height)
                }, completion: nil)
            }
        }
        else
        {
            btCompare.image = UIImage.init(named: "bt_comparar_vacio")
            btCompare.accessibilityIdentifier = "deselected"
            compareProducts = compareProducts - 1
            for productCompare: MDProduct in productsToCompare {
                if(productCompare == products[(btCompare.superview?.tag)!])
                {
                    productsToCompare.remove(at: productsToCompare.index(of: products[(btCompare.superview?.tag)!])!)
                }
            }
            
            for index: Int in indexProductsToCompare {
                if(index == (btCompare.superview?.tag)!)
                {
                   indexProductsToCompare.remove(at: indexProductsToCompare.index(of: index)!)
                }
            }

            if(compareProducts == 1)
            {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.viewCompareProducts.frame = CGRect(x:0, y:self.view.frame.size.height, width:self.viewCompareProducts.frame.size.width, height:self.viewCompareProducts.frame.size.height)
                    }, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancelComparetion(_ sender: AnyObject) {
        cancelComparetion()
        collectionView.reloadData()
    }
    
    func cancelComparetion()  {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.viewCompareProducts.frame = CGRect(x:0, y:self.view.frame.size.height, width:self.viewCompareProducts.frame.size.width, height:self.viewCompareProducts.frame.size.height)
            }, completion: nil)
        
        compareProducts = 0
        productsToCompare.removeAll()
        indexProductsToCompare.removeAll()
    }
    
    
    @IBAction func showViewCompareProducts(_ sender: AnyObject) {
       
        self.showViewCompareProduct()        
    }
    
    func showViewCompareProduct()  {
        
        let productsCompare = productsToCompare[0].sku + " - " + productsToCompare[1].sku
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Comparar Productos" as NSObject,
            kFIRParameterItemID: productsCompare as NSObject
            ])

        self.imageBlurCompare = UIImage().imageFromView(view: self.view)
        loading.starLoding(inView: self.view)
        let compareProductManager = MDCompareProducts()
        compareProductManager.compareProducts(firstProduct: productsToCompare[0].id, secondProduct: productsToCompare[1].id) { (hasError: Bool) in
            if(!hasError)
            {
                let viewController = MDCompareProductsViewController()
                viewController.img = self.imageBlurCompare
                viewController.compareProductManager = compareProductManager
                viewController.modalTransitionStyle = .coverVertical
                self.navigationController?.present(viewController, animated: true, completion: nil)
              //  self.present(viewController, animated: true, completion: nil)
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "compareProdcuts" as AnyObject, "products": compareProductManager.data as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
            }
            self.loading.stopLoding()
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
        self.navigationItem.addCategoriesToNavegationItem(viewController: self)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: true, viewController: self)
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
    
    //MARK: - FilterMenuDelegate
    func filterSelectedAction() {
        isFilter = false
        let array = MDFilterMenuViewController.filters.answerIDs.map({"\($0)"}).joined(separator: ",")
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Filtrar" as NSObject,
            kFIRParameterItemID: array as NSObject
            ])
        
        self.productsIds = (MDFilterMenuViewController.filters.productIds)
        self.resetProductController()
        self.cancelComparetion()
        self.loadProducts(offset: 0, limit: limitProductsShow)
     
    }
    
    func resetProductController()  {
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "removeProducts" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ResultProducts" as AnyObject])
        self.products.removeAll()
        productManager.products.removeAll()
        productShow = 7
        loadMoreProducts = true
        compareProducts = 0
        self.hideSideMenuView()
        viewCompareProducts.frame = CGRect(x:0, y:self.view.frame.size.height, width:self.view.frame.size.width, height:self.viewCompareProducts.frame.size.height)
    }
    
    //MARK: - Notification
    func continueShopping() {
        self.hideSideMenuView()
    }

    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
        //viewBlur.hidden = false
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
         self.navigationItem.addItemsRightToNavegationItem(withBtFilter: true, viewController: self)
        
        if(isFilter)
        {
            self.filterSelectedAction()
            isFilter = false
        }
    }
    
    
    //MARK: Notifications
    
    func markCellFromParisTvNotification(notification: NSNotification){
        let index = notification.object as! Int
        let lastIndexPath = NSIndexPath.init(row: lastIndex, section: 0)
        let  lastCell = collectionView .cellForItem(at: lastIndexPath as IndexPath)
        if(lastCell != nil)
        {
            lastCell?.backgroundColor = UIColor.white
            lastCell?.layer.borderWidth = 0
          //  MDTools.removeShadowTo(lastCell!.contentView)
        }

        let indexPath = NSIndexPath.init(row: index, section: 0)
        let  currentCell = collectionView .cellForItem(at: indexPath as IndexPath)
        if(currentCell != nil)
        {
            currentCell?.backgroundColor = UIColor.groupTableViewBackground
            currentCell?.layer.borderColor = UIColor.init(red:CGFloat(228/255.0), green: CGFloat(229/255.0), blue: CGFloat(234/255.0), alpha: 1.0).cgColor
            currentCell?.layer.borderWidth = 3
         //   MDTools.addShadowTo(currentCell!.contentView)
        }
        
        lastIndex = index
    }
    
    func continueToPay() {
        let loginSeller = MDLoginSellerPopUpViewController()
        loginSeller.modalPresentationStyle = .overCurrentContext
        loginSeller.modalTransitionStyle = .crossDissolve
        self.present(loginSeller, animated: true, completion: nil)
    }
    
    //MARK: Action Buttons
    @IBAction func closeOnBoard(_ sender: AnyObject) {
        if(scrollViewOnBoard != nil)
        {
            scrollViewOnBoard.removeFromSuperview()
            pageControl.removeFromSuperview()
            btCloseOnBoard.removeFromSuperview()
            isShowOnBoard = false
        }
    }
    
    deinit {
        print("ProducstViewController is being deallocated")
        if(isBack)
        {
            MDFilterMenuViewController.filters = MDFilterManager()
        }
        
       self.navigationController?.dismiss(animated: false, completion: nil)
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
