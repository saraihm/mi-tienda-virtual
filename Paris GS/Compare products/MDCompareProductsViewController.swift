//
//  MDCompareProductsViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 09-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDCompareProductsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ENSideMenuProtocol, ENSideMenuDelegate{
    let titleCellIdentifier = "TitleCellIdentifier"
    let contentCellIdentifier = "ContentCellIdentifier"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet var viewAddingShoppingCart: UIView!
    
    @IBOutlet weak var imgProduct1: UIImageView!
    @IBOutlet weak var lbDescriptionProduct1: UILabel!
    @IBOutlet weak var lbPriceProduct1: UILabel!
    @IBOutlet weak var btCartProduct1: UIButton!
    @IBOutlet weak var imgTarjetaCencosud1: UIImageView!
    @IBOutlet weak var contraintViewProduct1Width: NSLayoutConstraint!
    
    @IBOutlet weak var imgProduct2: UIImageView!
    @IBOutlet weak var lbDescriptionProduct2: UILabel!
    @IBOutlet weak var lbPriceProduct2: UILabel!
    @IBOutlet weak var btCartProduct2: UIButton!
    @IBOutlet weak var imgTarjetaCencosud2: UIImageView!
    
    var sideMenu : ENSideMenu?
    var sideMenuAnimationType : ENSideMenuAnimation = .Default
    var appDelegate: AppDelegate!
    
    //Variables obtained from another ViewController
    var img: UIImage!
    var imageBlur: UIImageView?
    var compareProductManager = MDCompareProducts()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true;
        MDTools.rounderBorderImage(imageView: imgProduct1)
        MDTools.rounderBorderImage(imageView: imgProduct2)
        
        if(compareProductManager.products[0].image != nil){
            imgProduct1.sd_setImage(with: URL.init(string: compareProductManager.products[0].image!), placeholderImage: UIImage.init(named: "cargando"))
        }
        else
        {
            imgProduct1.image = UIImage.init(named: "no_disponible")
        }

        self.lbDescriptionProduct1.text = compareProductManager.products[0].name
        self.btCartProduct1.tag = 0
        self.btCartProduct1.setBackgroundImage(UIImage.init(named: "bt_ver_carro"), for: .selected)
        let (bestPrice, _, _, isCencosud) = MDTools.price(prices: compareProductManager.products[0].prices)
        self.lbPriceProduct1.text =  bestPrice.value
        self.imgTarjetaCencosud1.isHidden = !isCencosud
        
        if(compareProductManager.products[1].image != nil){
            imgProduct2.sd_setImage(with: URL.init(string: compareProductManager.products[1].image!), placeholderImage: UIImage.init(named: "cargando"))
        }
        else
        {
            imgProduct2.image = UIImage.init(named: "no_disponible")
        }
        self.lbDescriptionProduct2.text = compareProductManager.products[1].name
        self.btCartProduct2.tag = 1
        self.btCartProduct2.setBackgroundImage(UIImage.init(named: "bt_ver_carro"), for: .selected)
        
        let (bestPrice1, _, _, isCencosud1) = MDTools.price(prices: compareProductManager.products[1].prices)
        self.lbPriceProduct2.text =  bestPrice1.value
        self.imgTarjetaCencosud2.isHidden = !isCencosud1

        verifyProductsInShoopingCart()
        
        contraintViewProduct1Width.constant = (UIScreen.main.bounds.width/2-UIScreen.main.bounds.width/10)-30
        
        imgBackground.image = img.applyExtraLightEffect()
        
        self.collectionView .register(UINib(nibName: "TitleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: titleCellIdentifier)
        self.collectionView .register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        
        // Config Paris tvOS
        appDelegate = UIApplication.shared.delegate as! AppDelegate

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sideMenuController()?.sideMenu?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueShopping), name:NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.continueToPay), name:NSNotification.Name(rawValue: "NotificationPay"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeout), name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)
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


    @IBAction func back(_ sender: AnyObject) {
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
        viewAddingShoppingCart.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK - UICollectionViewDataSource
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return compareProductManager.atributes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(indexPath.row, indexPath.section)
        if indexPath.row == 0 {
                let titleCell : TitleCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: titleCellIdentifier, for: indexPath as IndexPath) as! TitleCollectionViewCell
                titleCell.dateLabel.text = compareProductManager.atributes[indexPath.section].atributesName
                titleCell.dateLabel.font = UIFont.init(name: "OpenSans-Bold", size: 14)
                return titleCell
            } else {
                let contentCell : ContentCollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath as IndexPath) as! ContentCollectionViewCell
                
                contentCell.layer.borderColor = UIColor.groupTableViewBackground.cgColor
                contentCell.layer.borderWidth = 1
                contentCell.contentLabel.text = compareProductManager.atributes[indexPath.section].tagValues[indexPath.row-1]
                contentCell.contentLabel.font = UIFont.init(name: "OpenSans", size: 14)

                return contentCell
            }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row != 0)
        {
            let index = IndexPath.init(row: 0, section: indexPath.section)
            let currentCell = collectionView.cellForItem(at: indexPath as IndexPath)  as! ContentCollectionViewCell
            let currentCellTitle = collectionView.cellForItem(at: index)  as! TitleCollectionViewCell
            
            let descriptionLongPopUp = MDPopUpDescriptionViewController()
            descriptionLongPopUp.modalPresentationStyle = .overCurrentContext
            descriptionLongPopUp.modalTransitionStyle = .crossDissolve
            descriptionLongPopUp.descriptionLong = currentCell.contentLabel.text
            descriptionLongPopUp.titleDescription = currentCellTitle.dateLabel.text
            self.present(descriptionLongPopUp, animated: true, completion: nil)
            
        }
    }


    @IBAction func addToShoppingCart(_ sender: AnyObject) {
        let button = sender as! UIButton
        if(button.isSelected)
        {
            //viewBlur.hidden = false
            imageBlur = UIImageView.init(image: UIImage.init().imageFromView(view: self.view))
            imageBlur!.image = imageBlur!.image?.applyLightEffect()
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.hideSideMenu))
            imageBlur?.isUserInteractionEnabled = true
            imageBlur?.addGestureRecognizer(tapGesture)
            
            self.view.addSubview(imageBlur!)
            let viewController = MDShoppingCartViewController()
            viewController.fromCompareView = true
            self.sideMenu = ENSideMenu(sourceView: self.view, menuViewController: viewController, menuPosition:.Right)
            view.bringSubview(toFront: self.view)
            sideMenu!.menuWidth = UIScreen.main.bounds.width/2
            self.sideMenuController()?.sideMenu?.bouncingEnabled = false
            self.showSideMenuView()
            
        
        }
        else
        {
            FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
                kFIRParameterContentType: "Agregar al carro de comprar" as NSObject,
                kFIRParameterItemID: self.compareProductManager.products[button.tag].sku as NSObject
                ])
            
            button.isEnabled = false
            self.viewAddingShoppingCart.frame = CGRect(x:0, y:-self.viewAddingShoppingCart.frame.size.height, width:self.view.frame.size.width, height: self.viewAddingShoppingCart.frame.size.height)
            view.addSubview(viewAddingShoppingCart)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.viewAddingShoppingCart.frame = CGRect(x:0, y:0, width:self.viewAddingShoppingCart.frame.size.width, height:self.viewAddingShoppingCart.frame.size.height)
            MDShoppingCartViewController.shoppingCart.addProduct(product: self.compareProductManager.products[button.tag].copyProduct())
               MDShoppingCartViewController.shoppingCart.saveShoppingCart()
                
            }) { (Bool) in
                UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {
                    self.viewAddingShoppingCart.frame = CGRect(x:0, y:-self.viewAddingShoppingCart.frame.size.height, width: self.view.frame.size.width, height:self.viewAddingShoppingCart.frame.size.height)
                }) { (Bool) in
                    
                    button.isEnabled = true
                    button.isSelected = true
                }
            }
        }       
    }
    
    
    func setContentViewController(contentViewController: UIViewController) {
               
    }
    
    //MARK: - Notification
    func continueShopping() {
        viewAddingShoppingCart.removeFromSuperview()
        hideSideMenu()
        self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
        self.dismiss(animated: true, completion: nil)
    }

    func continueToPay() {
        let loginSeller = MDLoginSellerPopUpViewController()
        loginSeller.modalPresentationStyle = .overCurrentContext
        loginSeller.modalTransitionStyle = .crossDissolve
        loginSeller.fromCompareView = true
        self.present(loginSeller, animated: true, completion: nil)
    }

    
    func hideSideMenu() {
        print("sideMenuWillClose")
        verifyProductsInShoopingCart()
        if(imageBlur != nil)
        {
            imageBlur!.removeFromSuperview()
            imageBlur = nil
        }
        self.hideSideMenuView()        
    }
    
    func verifyProductsInShoopingCart() {
        
            btCartProduct1.isSelected = false
            btCartProduct2.isSelected = false

        for product in MDShoppingCartViewController.shoppingCart.products {
            if(product.sku == compareProductManager.products[0].sku)
            {
                btCartProduct1.isSelected = true
            }
            
            if(product.sku == compareProductManager.products[1].sku)
            {
                btCartProduct2.isSelected = true
            }
        }
    }
    
    func applicationDidTimeout()  {
        print("tiempo muerto en vista comparar")
        self.dismiss(animated: false, completion: nil)
    }
    
    deinit {
        print("MDCompareProducts is being deallocated")
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

 
}


