//
//  MDProductDetaillsViewController.swift
//  Paris GS
//
//  Created by Motion Displays on 14-11-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDProductDetaillsViewController:UIViewController, ENSideMenuDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,  CollectionViewSelectedProtocol, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    //Presentation view
    @IBOutlet weak var viewDiscount: UIView!
    @IBOutlet weak var lbDiscount: UILabel!
    @IBOutlet weak var lbTitleProduct: UILabel!
    @IBOutlet weak var lbSkuProduct: UILabel!
    @IBOutlet weak var btSimulate: UIButton!
    @IBOutlet weak var btClearSimulation: UIButton!
    @IBOutlet weak var lbAccumulatePoints: UILabel!
    @IBOutlet weak var collectionViewColors: UICollectionView!
    @IBOutlet weak var imgTarjetaCencosud: UIImageView!
    @IBOutlet weak var constraintRightLbPrices: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterBtSimulate: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImage: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterImage: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSimulate: NSLayoutConstraint!
    // @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var viewPresentation: UIView!
    @IBOutlet weak var scrollGalleryImg: UIScrollView!
    @IBOutlet weak var viewPrices: UIView!
    @IBOutlet weak var lbTitleBestPrice: UILabel!
    @IBOutlet weak var lbBestPrice: UILabel!
    @IBOutlet weak var lbTitleRegularPrice: UILabel!
    @IBOutlet weak var lbRegularPrice: UILabel!
    @IBOutlet weak var lbTitleNormalPrice: UILabel!
    @IBOutlet weak var lbNormalPrice: UILabel!
    
    //Details view
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewDetails: UIView!
    
    var simulatePopUp: MDSimulateViewController!
    
    
    var imageBlur: UIImageView?;
    
    var visibleCollectionReusableHeaderViews: NSMapTable<AnyObject, AnyObject>!
    
    var productImages = Array<String>()
    var productImagesTv = Array<String>()
    var isActiveSimulation = false
    var pageControl : UIPageControl!
    var oneTime = false
    
    var searchBar: UISearchBar!
    var searchResult = Array<MDSearch>()
    var tableView: UITableView!
    
    var filterManager = MDFilterManager()
    var variantsColor: MDVariatnDataSource?
    var firstTimeFichaProdcuto = true
    var firstTime = true
    var storedOffsets = [Int: CGFloat]()
    
    var appDelegate: AppDelegate!
    let userDefault = UserDefaults.standard
    
    //Variables obtained from another ViewController
    var productDetailsManager: MDProductDetailsManager!
    var product: MDProduct!
    var data: Array<MDProduct>!
    var dataRelacionados: Array<MDProduct>!
    var variantManager: MDVariantManager!
    var simulateEnviroment: MDSimulateEnviroment!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.addLogoToNavegationItem(viewController: self)
        self.navigationItem.addCategoriesToNavegationItem(viewController: self)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)
        self.sideMenuController()?.sideMenu?.bouncingEnabled = false
        
        viewPresentation.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        viewPresentation.layer.borderWidth = 1
        viewDetails.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        viewDetails.layer.borderWidth = 1
        
        //Presentation view
        lbTitleBestPrice.text = ""
        btSimulate.setTitle("Cambia tu ambiente", for: .selected)
        btSimulate.setBackgroundColor(color: COLOR_BLUE_LIGHT, forUIControlState: .selected)
        btSimulate.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        btSimulate.layer.borderWidth = 1
        btSimulate.layer.cornerRadius = kCornerRadiusButton
        
        btClearSimulation.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
        btClearSimulation.layer.borderWidth = 1
        btClearSimulation.layer.cornerRadius = kCornerRadiusButton
        
        // Config Paris tvOS
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        for variant in variantManager.variants
        {
            productDetailsManager.getProductPrice(product: variant, hasError: { (hasError: Bool) in
                
                variant.isUpdatedPrices = true
                if(self.variantManager.dataSource.count > 0 && self.productDetailsManager.productPresentation.has_colors)
                {
                    if(self.variantsColor?.currentVariant()!.id == variant.id)
                    {
                        self.configurePrices(prices: variant.prices)
                    }
                }
                else
                {
                    if(self.variantManager.variants[0].id == variant.id)
                    {
                        self.configurePrices(prices: variant.prices)
                    }
                }
            })
        }
        
        productDetailsManager.getProductPrice(product: productDetailsManager.productPresentation, hasError: { (hasError: Bool) in
            self.productDetailsManager.productPresentation.isUpdatedPrices = true
            if(self.variantManager.variants.count == 0)
            {
                self.configurePrices(prices: self.productDetailsManager.productPresentation.prices)
            }
        })
        
        if(userDefault.value(forKey: "linked_tv") == nil)
        {
            self.scrollGalleryImg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:  #selector(self.openGalleryImage)))
            self.productDetailsManager.productPresentation.preview = false
        }
        
        
        if(self.productDetailsManager.productPresentation.preview == false)
        {
            self.btSimulate.isHidden = true
        }
        
        product.name = self.productDetailsManager.productPresentation.name
        product.discount = self.productDetailsManager.productPresentation.discount
        
        self.lbSkuProduct.text = "SKU: " + productDetailsManager.productPresentation.sku
        product.sku = productDetailsManager.productPresentation.sku
        
        if(variantManager.variants.count == 0)
        {
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updateInfo" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "images": productDetailsManager.productPresentation.basicImagesTv as AnyObject, "description": productDetailsManager.productPresentation.name as AnyObject])
            
            self.lbTitleProduct.text = productDetailsManager.productPresentation.name
            
            if(productDetailsManager.productPresentation.discount != nil && productDetailsManager.productPresentation.discount != " " && productDetailsManager.productPresentation.discount != "-" )
            {
                viewDiscount.isHidden = false
                lbDiscount.text = product.discount
            }
            else
            {
                viewDiscount.isHidden = true
            }
            
            // self.configurePrices(prices: productDetailsManager.productPresentation.prices)
        }
        
        productImages = productDetailsManager.productPresentation.basicImages
        productImagesTv = productDetailsManager.productPresentation.basicImagesTv
        
        self.scrollGalleryImg.isPagingEnabled = true
        self.scrollGalleryImg.tag = 10
        
        
        //Details view
        collectionView.register(UINib.init(nibName: "MDFilterHeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerFilterCell")
        collectionView.register(UINib.init(nibName: "MDCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.register(UINib.init(nibName: "MDCollectionViewCellFicha", bundle: nil), forCellWithReuseIdentifier: "collectionViewCellFicha")
        collectionView.register(UINib.init(nibName: "MDDescriptionCell", bundle: nil), forCellWithReuseIdentifier: "descriptionCell")
        collectionView.register(UINib.init(nibName: "MDTextCell", bundle: nil), forCellWithReuseIdentifier: "textCell")
        collectionView.tag = 1
        visibleCollectionReusableHeaderViews = NSMapTable.init(keyOptions: .strongMemory, valueOptions: .weakMemory)
        
        
        //Search product
        searchBar = UISearchBar.init()
        searchBar.placeholder = "Buscar por palabra clave"
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundImage = UIImage()
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKind(of:UITextField.self) {
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
        
        //Get colors
        if (variantManager.dataSource.count > 0 && productDetailsManager.productPresentation.has_colors) {
            for dataSource in variantManager.dataSource {
                if(dataSource.type == "Color")
                {
                    variantsColor = dataSource
                    if((variantsColor?.dataSource.count)! == 1)
                    {
                        selectVariant(variant: (variantsColor?.currentVariant())!)
                        self.productDetailsManager.productPresentation.has_colors = false
                    }
                }
            }
        }
        else if(variantManager.variants.count > 0)
        {
            selectVariant(variant: variantManager.variants[0])
        }
        
        collectionViewColors.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionViewColors.tag = 0
        
        productDetailsManager.getAllProductsSimilar(productId: productDetailsManager.productPresentation.id, productClassId: productDetailsManager.productPresentation.productClassId) { (hasError: Bool) in
            
            self.productDetailsManager.getAllProductsRelative(productId: self.productDetailsManager.productPresentation.id, productClassId: self.productDetailsManager.productPresentation.productClassId) { (hasError: Bool) in
                
                self.data =  MDTools.subArray(array: self.productDetailsManager.productsSimilar, range: NSMakeRange(0, 3))
                self.dataRelacionados =  MDTools.subArray(array: self.productDetailsManager.productsRelative, range: NSMakeRange(0, 3))
                
                self.productDetailsManager.SectionFichaProducto = 0
                
                if(self.productDetailsManager.productPresentation.longDescription == nil)
                {
                    if (self.productDetailsManager.productsSimilar.count == 0 && self.productDetailsManager.productsRelative.count == 0)
                    {
                        self.productDetailsManager.numberOfSections = 1
                    }
                    else if(self.productDetailsManager.productsRelative.count == 0)
                    {
                        self.productDetailsManager.SectionProductosSimilares = 1
                        self.productDetailsManager.numberOfSections = 2
                    }
                    else if(self.productDetailsManager.productsSimilar.count == 0)
                    {
                        self.productDetailsManager.SectionProductosRelacionados = 1
                        self.productDetailsManager.numberOfSections = 2
                    }
                    else
                    {
                        self.productDetailsManager.SectionProductosSimilares = 1
                        self.productDetailsManager.SectionProductosRelacionados = 2
                        self.productDetailsManager.numberOfSections = 3
                    }
                }
                else
                {
                    self.productDetailsManager.SectionDescription = 1
                    
                    if (self.productDetailsManager.productsSimilar.count == 0 && self.productDetailsManager.productsRelative.count == 0)
                    {
                        self.productDetailsManager.numberOfSections = 2
                    }
                    else if(self.productDetailsManager.productsRelative.count == 0)
                    {
                        self.productDetailsManager.SectionProductosSimilares = 2
                        self.productDetailsManager.numberOfSections = 3
                    }
                    else if(self.productDetailsManager.productsSimilar.count == 0)
                    {
                        self.productDetailsManager.SectionProductosRelacionados = 2
                        self.productDetailsManager.numberOfSections = 3
                    }
                    else
                    {
                        self.productDetailsManager.SectionProductosSimilares = 2
                        self.productDetailsManager.SectionProductosRelacionados = 3
                        self.productDetailsManager.numberOfSections = 4
                    }
                }
                
                self.collectionView.reloadData()
                
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.addItemsRightToNavegationItem(withBtFilter: false, viewController: self)
        self.sideMenuController()?.sideMenu?.delegate = self
        print(scrollGalleryImg.frame)
        if(pageControl != nil)
        {
            
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "changeImage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "index": pageControl.currentPage as AnyObject])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueShopping), name:NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueToPay), name:NSNotification.Name(rawValue: "NotificationPay"), object: nil)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
        if(imageBlur != nil)
        {
            self.hideSideMenuView()
        }
        tableView.removeFromSuperview()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews", scrollGalleryImg.frame)
        if(oneTime == false)
        {
            adjustViewPresentation()
            if(scrollGalleryImg.frame.size.height != 280.0)
            {
                self.configurePageControl(images: productImages)
                self.setImageToScrollview(images: productImages)
                oneTime = true
            }
            
        }
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            MotionDisplaysAPI.cancelAllCurrentActiveOperations()
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
            MDProductsViewController.isComeFromProductDetails = true
        }
    }
    
    func adjustViewPresentation() {
        
        if(self.productDetailsManager.productPresentation.preview == false && self.productDetailsManager.productPresentation.has_colors == false)
        {
            self.constraintHeightImage.constant = 380
            self.constraintCenterImage.constant = -50
            self.collectionViewColors.isHidden = true
            
        }
        else if (self.productDetailsManager.productPresentation.has_colors == true && self.productDetailsManager.productPresentation.preview == false)
        {
            self.constraintHeightImage.constant = 350
            self.constraintCenterImage.constant = -80
            
        }
        else if (self.productDetailsManager.productPresentation.has_colors == false && self.productDetailsManager.productPresentation.preview == true)
        {
            self.constraintHeightImage.constant = 350
            self.constraintCenterImage.constant = -80
            self.constraintTopSimulate.constant = 30
            self.collectionViewColors.isHidden = true
        }
        
    }
    
    func openGalleryImage() {
        let viewController = MDGalleryImagesProductViewController()
        viewController.imagesProduct = productImages
        viewController.page = pageControl.currentPage
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func configurePrices(prices: Array<MDPrice>)  {
        
        let (bestPrice, regularPrice, normalPrice, isCencosud) = MDTools.price(prices: prices)
        
        self.lbBestPrice.text = bestPrice.value
        self.lbTitleBestPrice.text = bestPrice.name
        
        if(regularPrice != nil)
        {
            self.lbRegularPrice.text = regularPrice?.value
            self.lbTitleRegularPrice.text = regularPrice?.name
        }
        else
        {
            self.lbRegularPrice.text = ""
            self.lbTitleRegularPrice.text = ""
        }
        
        if(normalPrice != nil)
        {
            self.lbNormalPrice.text = normalPrice?.value
            self.lbTitleNormalPrice.text = normalPrice?.name
        }
        else
        {
            self.lbNormalPrice.text = ""
            self.lbTitleNormalPrice.text = ""
        }
        
        if(isCencosud)
        {
            self.lbTitleBestPrice.textColor = COLOR_RED
            self.imgTarjetaCencosud.isHidden = false
            self.constraintRightLbPrices.constant = 45
        }
        else
        {
            self.lbTitleBestPrice.textColor = COLOR_BLUE
            self.imgTarjetaCencosud.isHidden = true
            self.constraintRightLbPrices.constant = 0
        }
        
        var discount = ""
        
        if(product.discount != nil && product.discount != " " && product.discount != "-" )
        {
            discount = product.discount!
        }
        
        if(regularPrice != nil )
        {
            if(normalPrice != nil)
            {
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updatePrices" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject,"bestPrice": bestPrice.value as AnyObject, "regularPrice": regularPrice!.value as AnyObject, "normalPrice": normalPrice!.value as AnyObject, "titleBestPrice": bestPrice.name as AnyObject, "titleRegularPrice": regularPrice!.name as AnyObject, "titleNormalPrice": normalPrice!.name as AnyObject, "isCencosud": isCencosud as AnyObject, "discount": discount as AnyObject])
            }
            else
            {
                self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updatePrices" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject,"bestPrice": bestPrice.value as AnyObject, "regularPrice": regularPrice!.value as AnyObject, "normalPrice": "" as AnyObject, "titleBestPrice": bestPrice.name as AnyObject, "titleRegularPrice": regularPrice!.name as AnyObject, "titleNormalPrice": "" as AnyObject, "isCencosud": isCencosud as AnyObject, "discount": discount as AnyObject])
            }
        }
        else if(normalPrice != nil)
        {
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updatePrices" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject,"bestPrice": bestPrice.value as AnyObject, "regularPrice": normalPrice!.value as AnyObject, "normalPrice": "" as AnyObject, "titleBestPrice": bestPrice.name as AnyObject, "titleRegularPrice": normalPrice!.name as AnyObject, "titleNormalPrice": "" as AnyObject, "isCencosud": isCencosud as AnyObject, "discount": discount as AnyObject])
        }
        else
        {
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updatePrices" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject,"bestPrice": bestPrice.value as AnyObject, "regularPrice":"" as AnyObject, "normalPrice": "" as AnyObject, "titleBestPrice": bestPrice.name as AnyObject, "titleRegularPrice": "" as AnyObject, "titleNormalPrice": "" as AnyObject, "isCencosud": isCencosud as AnyObject, "discount": discount as AnyObject])
        }
    }
    
    func selectVariant(variant: MDVariant)  {
        self.lbSkuProduct.text = "SKU: " + variant.sku
        product.id = variant.id
        product.sku = variant.sku
        product.prices = variant.prices
        product.discount = variant.discount
        product.name = variant.name
        
        self.lbTitleProduct.text = product.name
        
        if(product.discount != nil && product.discount != " " && product.discount != "-" )
        {
            viewDiscount.isHidden = false
            lbDiscount.text = product.discount
        }
        else
        {
            viewDiscount.isHidden = true
        }
        
        if(variant.isUpdatedPrices)
        {
            self.configurePrices(prices: variant.prices)
        }
        
        if(isActiveSimulation)
        {
            productImages = variant.simulationImages
            productImagesTv = variant.simulationImagesTv
            if(productImages.count == 0)
            {
                productImages = productDetailsManager.productPresentation.simulationImages
                productImagesTv = productDetailsManager.productPresentation.simulationImagesTv
            }
        }
        else
        {
            productImages = variant.basicImages
            productImagesTv = variant.basicImagesTv
            if(productImages.count == 0)
            {
                productImages = productDetailsManager.productPresentation.basicImages
                productImagesTv = productDetailsManager.productPresentation.basicImagesTv
            }
            
        }
        
        if(productImages.count != 0)
        {
            product.image = productImages[0] + "?extendN=0.2%2C0.3%2C0.2%2C0.3"
        }
        
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updateInfo" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "images": productImagesTv as AnyObject, "description": product.name as AnyObject])
        
        self.configurePageControl(images: productImages)
        self.setImageToScrollview(images: productImages)
        changePage()
        
    }
    
    func setImageToScrollview(images: Array<String>) {
        scrollGalleryImg.contentSize = CGSize(width:scrollGalleryImg.frame.width * CGFloat.init(images.count), height: scrollGalleryImg.frame.height)
        
        print("scrollImageFrame", scrollGalleryImg.frame)
        
        if(images.count != 0)
        {
            for image: UIView in scrollGalleryImg.subviews {
                image.removeFromSuperview()
            }
            for index in 0...images.count-1 {
                let imageView = UIImageView.init(frame: CGRect(x:scrollGalleryImg.frame.width * CGFloat.init(index), y:0, width:scrollGalleryImg.frame.width, height:scrollGalleryImg.frame.height))
                let image = images[index]
                imageView.sd_setImage(with: URL.init(string: image), placeholderImage:  UIImage.init(named: "cargando"))
                imageView.contentMode = .scaleAspectFit
                scrollGalleryImg.addSubview(imageView)
            }
        }
        else
        {
            for image: UIView in scrollGalleryImg.subviews {
                image.removeFromSuperview()
            }
            let imageView = UIImageView.init(frame: CGRect(x:0, y:0, width:scrollGalleryImg.frame.width, height: scrollGalleryImg.frame.height))
            imageView.image = UIImage.init(named: "no_disponible")
            imageView.contentMode = .scaleAspectFit
            scrollGalleryImg.addSubview(imageView)
        }
    }
    
    func configurePageControl(images: Array<String>) {
        // The total number of pages that are available is based on how many available colors we have.
        if(self.pageControl != nil)
        {
            self.pageControl.removeFromSuperview()
        }
        self.pageControl = UIPageControl.init(frame: CGRect(x:self.scrollGalleryImg.frame.origin.x , y:self.scrollGalleryImg.frame.origin.y + self.scrollGalleryImg.frame.size.height + 66, width:self.scrollGalleryImg.frame.size.width, height:30))
        
        print("pageControlFrame", pageControl.frame)
        self.pageControl.addTarget(self, action: #selector(self.changePage), for: UIControlEvents.valueChanged)
        self.pageControl.numberOfPages = images.count
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor.groupTableViewBackground
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
        
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage() -> () {
        let x = CGFloat(pageControl.currentPage) * scrollGalleryImg.frame.size.width
        scrollGalleryImg.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.tag == 10)
        {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "changeImage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "index": pageNumber as AnyObject])
            pageControl.currentPage = Int(pageNumber)
            
        }
        
    }
    
    // MARK: - CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView.tag == 0)
        {
            if(self.productDetailsManager.productPresentation.has_colors)
            {
                return (variantsColor?.dataSource.count)!
            }
            return 0
        }
        
        print("section: ", section);
        
        if((self.filterManager.indexPathOpen) != nil) {
            if(self.filterManager.indexPathOpen!.section == section )
            {
                return 1
            }
        }
        else if(self.filterManager.firstTimeOpen)
        {
            if(section == productDetailsManager.SectionFichaProducto || section == productDetailsManager.SectionProductosSimilares || section == productDetailsManager.SectionProductosRelacionados)
            {
                return 1
            }
        }
        
        if(section == productDetailsManager.SectionProductosSimilares || section == productDetailsManager.SectionProductosRelacionados)
        {
            return 1
        }
        return 0;
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if(collectionView.tag == 0)
        {
            return 1
        }
        
        return productDetailsManager.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.tag == 0)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
            cell.layer.cornerRadius = 33/2;
            if(variantsColor?.dataSource != nil)
            {
                cell.backgroundColor =  UIColor().hexStringToUIColor(hex: ((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).value)!)
                if(variantsColor?.selectedValue == ((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).value)! && variantsColor?.selectedName == ((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).name))
                {
                    cell.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
                    cell.layer.borderWidth = 1
                    _ = cell.addExternalBorder(borderWidth: 6, borderColor: COLOR_BLUE_LIGHT, externalBoderRadius: 24.2)
                    cell.isSelected = true
                    self.selectVariant(variant: (variantsColor?.currentVariant())!)
                }
                else
                {
                    cell.removeExternalBorders()
                    cell.layer.borderColor = UIColor.black.cgColor
                    cell.layer.borderWidth = 1
                    cell.isSelected = false
                }
            }
            
            return cell
        }
        
        if(collectionView.tag == 1)
        {
            if(indexPath.section == productDetailsManager.SectionFichaProducto )
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCellFicha", for: indexPath as IndexPath) as! MDCollectionViewCellFicha
                return cell
            }
            
            if(indexPath.section == productDetailsManager.SectionDescription)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath as IndexPath) as! MDDescriptionCell
                if(productDetailsManager.productPresentation.longDescription != nil)
                {
                    let url = NSURLRequest(url: NSURL(string: productDetailsManager.productPresentation.longDescription!)! as URL)
                    cell.webView?.frame = CGRect(x:13, y:0, width:cell.frame.size.width-30, height:cell.frame.size.height-15)
                    cell.webView!.load(url as URLRequest)
                    cell.webView?.scrollView.isDirectionalLockEnabled = true
                }
                
                return cell
            }
            
            if(indexPath.section == productDetailsManager.SectionProductosSimilares || indexPath.section == productDetailsManager.SectionProductosRelacionados)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath as IndexPath) as! MDCollectionViewCell
                return cell
            }
            
            if(indexPath.section == productDetailsManager.SectionComentarios)
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath as IndexPath) as! MDTextCell
                cell.lbText.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"
                return cell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath as IndexPath) as! MDTextCell
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerFilterCell", for: indexPath as IndexPath) as! MDFilterHeaderCell
        
        header.lbTitleFilter.textColor = COLOR_GRAY_LIGHT
        
        header.open = false
        header.checked = false
        header.lbTitleFilter.font = UIFont.init(name: "AzoSans-Medium", size: 14)
        
        if(indexPath.section == productDetailsManager.SectionFichaProducto)
        {
            header.lbTitleFilter.text = "FICHA TÉCNICA"
            header.imgRow.isHidden = false
            if(self.filterManager.indexPathOpen == nil && self.filterManager.firstTimeOpen == true)
            {
                self.filterManager.indexPathOpen = indexPath as NSIndexPath?
                self.filterManager.firstTimeOpen = false
                header.open = true
            }
            
            let border = CALayer()
            border.name = "border"
            let with = CGFloat(1.0)
            border.borderColor = UIColor.groupTableViewBackground.cgColor
            border.frame = CGRect(x:0, y: header.frame.size.height - with, width: header.frame.size.width, height: header.frame.size.height)
            border.borderWidth = with
            header.layer.addSublayer(border)
            header.layer.masksToBounds = true
            header.imgRow.image = UIImage.init(named: "bt_ficha_expandir")
            header.imgRow.isHidden = false
            
            
        }
        else if(indexPath.section == productDetailsManager.SectionDescription )
        {
            header.lbTitleFilter.text = "DESCRIPCIÓN"
            let border = CALayer()
            border.name = "border"
            let with = CGFloat(1.0)
            border.borderColor = UIColor.groupTableViewBackground.cgColor
            border.frame = CGRect(x:0, y: header.frame.size.height - with, width: header.frame.size.width, height: header.frame.size.height)
            border.borderWidth = with
            header.layer.addSublayer(border)
            header.layer.masksToBounds = true
            header.imgRow.image = UIImage.init(named: "bt_ficha_expandir")
            header.imgRow.isHidden = false
        }
        else if(indexPath.section == productDetailsManager.SectionProductosSimilares)
        {
            header.lbTitleFilter.text = "PRODUCTOS SIMILARES"
            if(data.count <= 3)
            {
                header.imgRow.isHidden = true
            }
            header.layer.sublayers?.forEach {
                if($0.name == "border")
                {
                    $0.removeFromSuperlayer()
                }
            }
        }
        else if(indexPath.section == productDetailsManager.SectionComentarios )
        {
            header.lbTitleFilter.text = "COMENTARIOS"
            let border = CALayer()
            border.name = "border"
            let with = CGFloat(1.0)
            border.borderColor = UIColor.groupTableViewBackground.cgColor
            border.frame = CGRect(x:0, y: header.frame.size.height - with, width: header.frame.size.width, height: header.frame.size.height)
            border.borderWidth = with
            header.layer.addSublayer(border)
            header.layer.masksToBounds = true
            header.imgRow.image = UIImage.init(named: "bt_ficha_expandir")
            header.imgRow.isHidden = false
        }
        else if(indexPath.section == self.productDetailsManager.SectionProductosRelacionados)
        {
            header.lbTitleFilter.text = "PRODUCTOS RELACIONADOS"
            if(data.count <= 3)
            {
                header.imgRow.isHidden = true
            }
            header.layer.sublayers?.forEach {
                if($0.name == "border")
                {
                    $0.removeFromSuperlayer()
                }
            }
        }
        
        
        if(self.filterManager.firstTimeOpen == false && self.filterManager.indexPathOpen != nil )
        {
            if(indexPath.section == self.filterManager.indexPathOpen?.section)
            {
                header.open = true
                header.layer.sublayers?.forEach {
                    if($0.name == "border")
                    {
                        $0.removeFromSuperlayer()
                    }
                }
                
                header.imgRow.image = UIImage.init(named: "bt_ficha_comprimir")
            }
            else if(indexPath.section != productDetailsManager.SectionProductosSimilares && indexPath.section != productDetailsManager.SectionProductosRelacionados)
            {
                let border = CALayer()
                border.name = "border"
                let with = CGFloat(1.0)
                border.borderColor = UIColor.groupTableViewBackground.cgColor
                border.frame = CGRect(x:0, y: header.frame.size.height - with, width: header.frame.size.width, height: header.frame.size.height)
                border.borderWidth = with
                header.layer.addSublayer(border)
                header.layer.masksToBounds = true
                header.imgRow.image = UIImage.init(named: "bt_ficha_expandir")
            }
            
            print("toggleOpenWithUserAction: false")
            header.toggleOpenWithUserActionDetailProduct(userAction: false) { (willOpen: Bool) in
            }
        }
        
        let headerRecognizar = MDFilterHeaderTapRecognizer(target: self, action: #selector(self.headerTapped(sender:)))
        
        header.addGestureRecognizer(headerRecognizar)
        visibleCollectionReusableHeaderViews .setObject(header, forKey: indexPath as AnyObject?)
        headerRecognizar.indexPath = indexPath as NSIndexPath!
        headerRecognizar.recognizerType =  3
        
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        print(indexPath.section, indexPath.row)
        
        if (indexPath.section == productDetailsManager.SectionFichaProducto)
        {
            guard let collectionViewCell = cell as? MDCollectionViewCellFicha else {
                return
            }
            let dataProvider = MDFichaTecnicaCellChildDataSource()
            dataProvider.data = self.productDetailsManager.productTechnicalData
            let delegate = MDFichaTecnicaCellChidlViewDelegate()
            collectionViewCell.setCollectionViewDataSourceDelegat(dataSource: dataProvider, delegate: delegate, forRow: indexPath.row)
            collectionViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        }
        
        
        if (indexPath.section == self.productDetailsManager.SectionProductosSimilares || indexPath.section == self.productDetailsManager.SectionProductosRelacionados)
        {
            guard let collectionViewCell = cell as? MDCollectionViewCell else {
                return
            }
            let dataProvider = MDProductCellChildDataSource()
            collectionViewCell.setCollectionViewDataSourceDelegate(dataSource: dataProvider, forRow: indexPath.section)
            collectionViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
            collectionViewCell.delegate = self
            if(indexPath.section == self.productDetailsManager.SectionProductosSimilares)
            {
                dataProvider.data = self.data
                if(self.productDetailsManager.productsSimilar.count <= 3 || dataProvider.data.count > 3)
                {
                    collectionViewCell.btShowAll.isHidden = true
                }
                else
                {
                    collectionViewCell.btShowAll.isHidden = false
                }
            }
            else
            {
                dataProvider.data = self.dataRelacionados
                if(self.productDetailsManager.productsRelative.count <= 3 || dataProvider.data.count > 3)
                {
                    collectionViewCell.btShowAll.isHidden = true
                }
                else
                {
                    collectionViewCell.btShowAll.isHidden = false
                }
                
            }
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? MDCollectionViewCell else { return }
        storedOffsets[indexPath.row] = collectionViewCell.collectionViewOffset
    }
    
    
    // MARK: - CollectionViewDelegateLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(collectionView.tag == 1)
        {
            return CGSize(width:self.collectionView.frame.width, height:40)
            
        }
        return CGSize(width:0, height:0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView.tag == 0)
        {
            return CGSize(width:33, height:33)
        }
        if(collectionView.tag == 1)
        {
            if(indexPath.section == self.productDetailsManager.SectionFichaProducto)
            {
                if(self.productDetailsManager.productTechnicalData.count > 10)
                {
                    return CGSize(width:self.collectionView.frame.width, height:520)
                }
                else
                {
                    return CGSize(width:self.collectionView.frame.width, height:CGFloat(self.productDetailsManager.productTechnicalData.count)*50+20)
                }
            }
            else if(indexPath.section == self.productDetailsManager.SectionDescription)
            {
                return CGSize(width:self.collectionView.frame.width, height:420)
            }
            else if(indexPath.section == productDetailsManager.SectionProductosSimilares)
            {
                if(data.count <= 3)
                {
                    return CGSize(width:self.collectionView.frame.width, height:CGFloat(3*230/3) + 55)
                }
                return CGSize(width:self.collectionView.frame.width, height:CGFloat(6*250/3))
            }
            else if(indexPath.section == productDetailsManager.SectionComentarios)
            {
                return CGSize(width:self.collectionView.frame.width, height:220)
            }
            else if(indexPath.section == productDetailsManager.SectionProductosRelacionados)
            {
                if(dataRelacionados.count <= 3)
                {
                    return CGSize(width:self.collectionView.frame.width, height:CGFloat(3*230/3) + 55)
                }
                return CGSize(width:self.collectionView.frame.width, height:CGFloat(6*250/3))
            }
            
            return CGSize(width:self.collectionView.frame.width, height:50)
        }
        return CGSize(width:self.collectionView.frame.width, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView.tag == 0)
        {
            return 40
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        if(collectionView.tag == 0)
        {
            if(variantsColor?.dataSource != nil)
            {
                if((variantsColor?.dataSource.count)!<7)
                {
                    let totalCellWidth = 25 * (variantsColor?.dataSource.count)!
                    let totalSpacingWidth = 40 * ((variantsColor?.dataSource.count)! - 1)
                    
                    let leftInset = (collectionViewColors.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2;
                    let rightInset = leftInset
                    
                    return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
                }
                else
                {
                    return UIEdgeInsetsMake(0, 18.2, 0, 40);
                }
                
            }
        }
        
        return  UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 0 )
        {
            if(variantsColor?.selectedName != ((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).name) || variantsColor?.selectedValue != ((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).value)!)
            {
                print("select cell no: \(indexPath.row)")
                let currentCell = collectionView.cellForItem(at: indexPath as IndexPath)
                currentCell?.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
                currentCell?.layer.borderWidth = 1
                _ = currentCell?.addExternalBorder(borderWidth: 6, borderColor: COLOR_BLUE_LIGHT, externalBoderRadius: 24.2)
                variantsColor?.setSelectionWithValue(((variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).value)!, name: (variantsColor?.dataSource[indexPath.row] as! MDVariantProperty).name)
                collectionViewColors.reloadData()
            }
        }
        else
        {
            print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        /*   if(collectionView.tag == 0 )
         {
         print("deselect cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
         let currentCell = collectionView.cellForItemAtIndexPath(indexPath)
         currentCell?.layer.borderColor = UIColor.blackColor().CGColor
         currentCell?.layer.borderWidth = 1
         currentCell?.removeExternalBorders()
         }
         */
    }
    
    
    func headerTapped(sender: MDFilterHeaderTapRecognizer)  {
        
        print("Header tapped for index Section ", sender.indexPath.section)
        
        // if( sender.indexPath != self.filterManager.indexPathOpen)
        // {
        if(sender.indexPath.section == self.productDetailsManager.SectionProductosSimilares || sender.indexPath.section == self.productDetailsManager.SectionProductosRelacionados)
        {
            return
        }
        
        let header = visibleCollectionReusableHeaderViews.object(forKey: sender.indexPath) as! MDFilterHeaderCell
        header.layer.sublayers?.forEach {
            if($0.name == "border")
            {
                $0.removeFromSuperlayer()
            }
        }
        
        header.toggleOpenWithUserActionDetailProduct(userAction: true) { (willOpen: Bool) in
            
            var sectionChanged = false
            
            if(sender.indexPath != self.filterManager.indexPathOpen && self.filterManager.indexPathOpen != nil)
            {
                print("different section open")
                sectionChanged = true
            }
            
            if (willOpen) {
                self.openSection(localCurrentIndexPath: sender.indexPath, sectionChanged:sectionChanged)
            }
            else
            {
                self.closeSection(indexPath: sender.indexPath, sectionChanged:false)
                //  self.collectionView.reloadSections(NSIndexSet(index: sender.indexPath.section) as IndexSet)
            }
            
            
            self.collectionView.reloadSections(NSIndexSet(indexesIn: NSMakeRange(0, self.productDetailsManager.numberOfSections)) as IndexSet)
            
        }
        // }
        
    }
    
    func openSection(localCurrentIndexPath: NSIndexPath, sectionChanged: Bool) {
        print("sectionHeaderView:sectionOpened:", localCurrentIndexPath.section)
        
        let localLastIndexPath = self.filterManager.indexPathOpen
        self.filterManager.setIndexPathOpenDetailsProduct(indexPathOpen: localCurrentIndexPath, linesTotal: 0)
        //  let currentSection = filtersArray[(localCurrentIndexPath.section)]
        
        print("SECTION OPENED: ", localCurrentIndexPath.section)
        
        if(sectionChanged == true || self.filterManager.firstTimeOpen == true)
        {
            self.filterManager.firstTimeOpen = false
        }
        
        collectionView .performBatchUpdates({
            
            /*
             Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
             */
            var indexPathsToInsert = Array<NSIndexPath>()
            
            indexPathsToInsert.append(NSIndexPath (row: localCurrentIndexPath.row, section: localCurrentIndexPath.section))
            
            if(indexPathsToInsert.count > 0)
            {
                self.collectionView.insertItems(at: indexPathsToInsert as [IndexPath])
                
            }
            
            if(sectionChanged == true && localLastIndexPath != nil && localLastIndexPath?.section != self.productDetailsManager.SectionProductosSimilares  && localLastIndexPath?.section != self.productDetailsManager.SectionProductosRelacionados)
            {
                self.closeSection(indexPath: localLastIndexPath!, sectionChanged: true)
            }
            
            if(localLastIndexPath != nil && localLastIndexPath?.section == self.productDetailsManager.SectionProductosSimilares || localLastIndexPath?.section == self.productDetailsManager.SectionProductosRelacionados)
            {
                let  lastCell = self.collectionView.cellForItem(at: localLastIndexPath! as IndexPath) as! MDCollectionViewCell
                if(localLastIndexPath?.section == self.productDetailsManager.SectionProductosSimilares)
                {
                    self.data.removeSubrange(Range(3..<self.data.count))
                    (lastCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.data
                }
                else
                {
                    self.dataRelacionados.removeSubrange(Range(3..<self.dataRelacionados.count))
                    (lastCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.dataRelacionados
                }
                
                lastCell.collectionView.reloadData()
                lastCell.btShowAll.isHidden = false
                self.collectionView.collectionViewLayout.invalidateLayout()
                
            }
            
        }) { (Bool) in
            
        }
    }
    
    func closeSection(indexPath: NSIndexPath, sectionChanged: Bool) {
        
        //Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
        
        print("sectionHeaderView:sectionClosed:", indexPath.section)
        
        collectionView .performBatchUpdates({
            
            let countOfRowsToDelete = self.collectionView.numberOfItems(inSection: indexPath.section)
            
            if(countOfRowsToDelete > 0)
            {
                var indexPathsToDelete = Array<NSIndexPath>()
                for index in 0...countOfRowsToDelete-1
                {
                    indexPathsToDelete.append(NSIndexPath (row: index, section: indexPath.section))
                }
                self.collectionView.deleteItems(at: indexPathsToDelete as [IndexPath])
            }
            
            if(sectionChanged == false)
            {
                self.filterManager.setIndexPathOpenDetailsProduct(indexPathOpen: nil, linesTotal: 0)
                self.filterManager.firstTimeOpen = false
            }
            
            
        }) { (Bool) in
            
        }
        
        
    }
    
    // MARK: - CollectionViewSelectedProtocol
    
    func collectionViewSelected(collectionView: Int, item: Int) {
        
        var products: Array<MDProduct>!
        if(collectionView == productDetailsManager.SectionProductosSimilares)
        {
            products = self.data
        }
        else
        {
            products = self.dataRelacionados
        }
        
        let productDetails = MDProductDetailsManager()
        let loading = MDLoadingView.init(frame: self.view.bounds)
        loading.starLoding(inView: self.view)
        productDetails.getProductDetails(productId: products[item].id, productClass: productDetailsManager.productPresentation.productClassId!) { (hasError: Bool) in
            
            if(hasError == false)
            {
                FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                    kFIRParameterContentType: "Producto visto" as NSObject,
                    kFIRParameterItemID: products[item].sku as NSObject
                    ])
                
                if(products[item].discount != nil && products[item].discount != "" && products[item].discount != "-")
                {
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "reloadPage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "discount": products[item].discount! as AnyObject])
                }
                else
                {
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "reloadPage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "discount": "" as AnyObject])
                }
                
                
                productDetails.SectionFichaProducto = 0
                
                if(productDetails.productPresentation.longDescription == nil)
                {
                    productDetails.numberOfSections = 1
                }
                else
                {
                    productDetails.SectionDescription = 1
                    productDetails.numberOfSections = 2
                }
                
                let variantManager = MDVariantManager.init(variants: productDetails.productVariations)
                
                let viewController = MDProductDetailViewController()
                viewController.productDetailsManager = productDetails
                viewController.product = products[item].copyProduct()
                viewController.variantManager = variantManager
                self.navigationController?.pushViewController(viewController, animated: false)
                UIView.transition(with: (self.navigationController?.view)!, duration: 1, options: .transitionFlipFromRight, animations: nil, completion: nil)
                
            }
            
            loading.stopLoding()
            
        }
        
    }
    
    func collectionViewShowAllProducts(collectionViewItem: Int, moreItems: Bool) {
        if(moreItems)
        {
            if(collectionViewItem == self.productDetailsManager.SectionProductosSimilares)
            {
                self.data = self.productDetailsManager.productsSimilar
                self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem: collectionViewItem)
            }
            else
            {
                self.dataRelacionados = self.productDetailsManager.productsRelative
                self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem: collectionViewItem)
            }
            
            /*
             if(collectionViewItem == productDetailsManager.SectionProductosSimilares)
             {
             if(self.productDetailsManager.productsSimilar.count <= 3)
             {
             let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
             loadingNotification.labelText = "Cargando..."
             productDetailsManager.getAllProductsSimilar(product.id, productClassId: product.classId!, hasError: { (hasError: Bool) in
             
             if(hasError == false)
             {
             self.data = self.productDetailsManager.productsSimilar
             self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem)
             }
             MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
             })
             }
             else
             {
             self.data = self.productDetailsManager.productsSimilar
             self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem)
             }
             }
             else if(collectionViewItem == productDetailsManager.SectionProductosRelacionados)
             {
             if(self.productDetailsManager.productsRelative.count <= 3)
             {
             let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
             loadingNotification.labelText = "Cargando..."
             productDetailsManager.getAllProductsRelative(product.id, hasError: { (hasError: Bool) in
             
             if(hasError == false)
             {
             self.dataRelacionados = self.productDetailsManager.productsRelative
             self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem)
             }
             
             MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
             })
             }
             else
             {
             self.dataRelacionados = self.productDetailsManager.productsRelative
             self.buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem)
             }
             }*/
        }
    }
    
    func buildMoreOrLesSimilarOrRelativeProducts(collectionViewItem: Int)
    {
        let  currentCell = self.collectionView .cellForItem(at: NSIndexPath(row: 0, section: collectionViewItem) as IndexPath)as! MDCollectionViewCell
        if(collectionViewItem == self.productDetailsManager.SectionProductosSimilares)
        {
            (currentCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.data
        }
        else
        {
            (currentCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.dataRelacionados
            currentCell.btShowAll.isHidden = true
        }
        
        currentCell.collectionView.reloadData()
        
        if(self.filterManager.indexPathOpen?.section == self.productDetailsManager.SectionProductosSimilares || self.filterManager.indexPathOpen?.section == self.productDetailsManager.SectionProductosRelacionados)
        {
            let  lastCell = self.collectionView.cellForItem(at: self.filterManager.indexPathOpen! as IndexPath) as! MDCollectionViewCell
            if(self.filterManager.indexPathOpen?.section == self.productDetailsManager.SectionProductosSimilares)
            {
                self.data.removeSubrange(Range(3..<self.data.count))
                (lastCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.data
            }
            else
            {
                self.dataRelacionados.removeSubrange(Range(3..<self.dataRelacionados.count))
                (lastCell.collectionView.dataSource as! MDProductCellChildDataSource).data = self.dataRelacionados
                lastCell.btShowAll.isHidden = false
            }
            
            lastCell.collectionView.reloadData()
            
        }
        else if(self.filterManager.indexPathOpen != nil)
        {
            self.closeSection(indexPath: self.filterManager.indexPathOpen!, sectionChanged: false)
        }
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.filterManager.indexPathOpen = NSIndexPath(row: 0, section: collectionViewItem)
        
        self.collectionView.reloadSections(NSIndexSet(indexesIn: NSMakeRange(0, self.productDetailsManager.numberOfSections)) as IndexSet)
        
        
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
        let label = UILabel.init(frame: CGRect(x:170, y:0, width: self.tableView.frame.size.width, height: 50))
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
        let productsIds = searchResult[indexPath.row].productsId
        MDFilterMenuViewController.filters.answerIDs = Array<NSNumber>()
        MDFilterMenuViewController.filters.getFiltersWith(productsID: productsIds, hasError: { (hasError: Bool) in
            if(hasError == false)
            {
                MDFilterMenuViewController.filters.filterWithProductsId = true
                MDFilterMenuViewController.productsId = productsIds
            }
        })
        
        let viewController = MDProductsViewController()
        viewController.productsIds = productsIds
        viewController.titleName = searchResult[indexPath.row].title
        viewController.subTitleName = searchResult[indexPath.row].subTitle
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        self.navigationController!.view.layer.add(transition, forKey: nil)
        self.navigationController!.pushViewController(viewController, animated: false)
        hideSearchBar()
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
        let loading = MDLoadingView.init(frame: self.view.bounds)
        loading.starLoding(inView: self.view)
        let searchProduct = MDSearchManager()
        searchProduct.searchProduct(key: searchBar.text!, hasError: { (hasError: Bool) in
            if(hasError == false)
            {
                self.searchResult = searchProduct.resultSkus
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            
            loading.stopLoding()
            
        })
        
    }
    
    //MARK: - Buttons Actions
    
    @IBAction func simulate(_ sender: UIButton) {
        
        if(sender.isSelected == false)
        {
            FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                kFIRParameterContentType: "Simular ambiente" as NSObject,
                kFIRParameterItemID: product.sku as NSObject
                ])
            
            sender.isSelected = true
            isActiveSimulation = true
            constraintCenterBtSimulate.constant = -35
            btClearSimulation.isHidden = false
            
            if(variantsColor != nil && variantsColor?.dataSource != nil && productDetailsManager.productPresentation.has_colors)
            {
                variantManager.dataSource[0].setDataSource(variantManager.variants, setSelection: true, withSimulation: true)
                collectionViewColors.reloadData()
                selectVariant(variant: (variantsColor?.currentVariant())!)
            }
            else if(variantManager.variants.count > 0)
            {
                productImages = variantManager.variants[0].simulationImages
                productImagesTv = variantManager.variants[0].simulationImagesTv
            }
            else
            {
                productImages = productDetailsManager.productPresentation.simulationImages
                productImagesTv = productDetailsManager.productPresentation.simulationImagesTv
            }
            
            self.configurePageControl(images: productImages)
            self.setImageToScrollview(images: productImages)
            changePage()
            
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updateImages" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "images": productImagesTv as AnyObject])
        }
        
        if(simulateEnviroment == nil)
        {
            let loading = MDLoadingView.init(frame: self.view.bounds)
            loading.starLoding(inView: self.view)
            
            simulateEnviroment = MDSimulateEnviroment()
            simulateEnviroment.getSimulateEnviromentOptions(classID: productDetailsManager.productPresentation.productClassId!, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    self.simulatePopUp = MDSimulateViewController()
                    self.simulatePopUp.modalPresentationStyle = .overCurrentContext
                    self.simulatePopUp.modalTransitionStyle = .crossDissolve
                    
                    self.simulatePopUp.simulateEnviroment = self.simulateEnviroment
                    self.present(self.simulatePopUp, animated: true, completion: nil)
                    self.appDelegate.sendInstructionToParisTV(instruction: ["action": "changeImage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "index": self.pageControl.currentPage as AnyObject])
                }
                
                loading.stopLoding()
            })
        }
        else
        {
            self.simulatePopUp.simulateEnviroment = simulateEnviroment
            self.present(self.simulatePopUp, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func clearSimulation(_ sender: AnyObject) {
        constraintCenterBtSimulate.constant = 0
        btClearSimulation.isHidden = true
        isActiveSimulation = false
        btSimulate.isSelected = false
        
        if(variantsColor != nil && variantsColor?.dataSource != nil && productDetailsManager.productPresentation.has_colors)
        {
            variantManager.dataSource[0].setDataSource(variantManager.variants, setSelection: true, withSimulation: false)
            collectionViewColors.reloadData()
            selectVariant(variant: (variantsColor?.currentVariant())!)
        }
        else if(variantManager.variants.count > 0)
        {
            productImages = variantManager.variants[0].basicImages
            productImagesTv = variantManager.variants[0].basicImagesTv
        }
        else
        {
            productImages = productDetailsManager.productPresentation.basicImages
            productImagesTv = productDetailsManager.productPresentation.basicImagesTv
        }
        
        self.configurePageControl(images: productImages)
        self.setImageToScrollview(images: productImages)
        changePage()
        
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "clearSimulation" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject])
        
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "updateImages" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "images": productImagesTv as AnyObject])
        
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "changeImage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "index": pageControl.currentPage as AnyObject])
        
    }
    
    @IBAction func btAddCartAction(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Agregar al carro de comprar" as NSObject,
            kFIRParameterItemID: product.sku as NSObject
            ])
        
        MDShoppingCartViewController.shoppingCart.addProduct(product: product.copyProduct())
        MDShoppingCartViewController.shoppingCart.saveShoppingCart()
        self.setMenuShoppingCart(sender: self.navigationItem.rightBarButtonItem?.customView?.viewWithTag(4) as! UIButton)
    }
    
    //MARK: - Notification
    func continueShopping() {
        self.hideSideMenuView()
        //_ = self.navigationController?.popViewController(animated: true)
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
    
    deinit {
        print("MDProductDetailViewController is being deallocated")
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize.zero
        layout.sectionInset = UIEdgeInsets.zero
        layout.headerReferenceSize = CGSize.zero
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
