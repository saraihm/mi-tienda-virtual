//
//  MDShoppingCartViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 03-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import Firebase

class MDShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellSelectedDelegate {

    @IBOutlet weak var lbQuantityProducts: UILabel!
    @IBOutlet weak var lbTotalPriceHeader: UILabel!
    @IBOutlet weak var lbTotalPriceText: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var btContinueShopping: UIButton!
    @IBOutlet weak var btCleanCart: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btPay: UIButton!
    @IBOutlet weak var imgShoppingCart: UIImageView!
    @IBOutlet weak var viewEmptyCart: UIView!
    @IBOutlet weak var contrainsTopSpace: NSLayoutConstraint!
    
    var fromCompareView = false
    static var shoppingCart = MDShoppingCart()
    
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        if(fromCompareView)
        {
            contrainsTopSpace.constant = 10
        }
        
        btContinueShopping.layer.borderColor = COLOR_GRAY_DARK.cgColor
        btContinueShopping.layer.borderWidth = 1
        btContinueShopping.layer.cornerRadius = kCornerRadiusButton
        
        btCleanCart.layer.borderColor = COLOR_GRAY_DARK.cgColor
        btCleanCart.layer.borderWidth = 1
        btCleanCart.layer.cornerRadius = kCornerRadiusButton
        
        btPay.layer.cornerRadius = kCornerRadiusButton

        
        updatePriceLabels()
                
        tableView.register(UINib.init(nibName: "MDShoppingCartCell", bundle: nil), forCellReuseIdentifier: "shoppingCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewEmptyCart.isHidden = true
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MDShoppingCartViewController.shoppingCart.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath as IndexPath) as! MDShoppingCartCell
        cell.backgroundColor = UIColor.groupTableViewBackground
        if(MDShoppingCartViewController.shoppingCart.products[indexPath.row].image != nil){
            cell.imgProduct.sd_setImage(with: URL.init(string: MDShoppingCartViewController.shoppingCart.products[indexPath.row].image!), placeholderImage: UIImage.init(named: "cargando"))
        }
        else
        {
            cell.imgProduct.image = UIImage.init(named: "no_disponible")
        }
        
        cell.lbDescription.text = MDShoppingCartViewController.shoppingCart.products[indexPath.row].name
        cell.lbSku.text = "SKU " + MDShoppingCartViewController.shoppingCart.products[indexPath.row].sku
        cell.quantityProduct = MDShoppingCartViewController.shoppingCart.products[indexPath.row].quantity
        if(MDShoppingCartViewController.shoppingCart.products[indexPath.row].quantity < 10)
        {
            cell.lbQuantity.text = "0"+String(MDShoppingCartViewController.shoppingCart.products[indexPath.row].quantity)
        }
        else
        {
            cell.lbQuantity.text = String(MDShoppingCartViewController.shoppingCart.products[indexPath.row].quantity)
        }
        
        let (bestPrice, normalPrice, _, isCencosud) = MDTools.price(prices: MDShoppingCartViewController.shoppingCart.products[indexPath.row].prices)
        
        cell.lbPrice.text = bestPrice.value
        if(normalPrice != nil)
        {
            cell.lbNormalPrice.text = (normalPrice?.name)! + " " + (normalPrice?.value)!
        }
      
        cell.imgTarjetaCencosud.isHidden = !isCencosud

        cell.btRemoveProduct.tag = indexPath.row
        cell.btMore.tag = indexPath.row
        cell.btLess.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
    
     // MARK: - TableView Delegate
    func tableViewCellSelected(index: Int) {
        let indexPath = NSIndexPath.init(row: index, section: 0)
        MDShoppingCartViewController.shoppingCart.deleteProduct(index: index)
        tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        tableView.reloadData()
        updatePriceLabels()
        
    }
    
    func tableViewCellMoreProduct(index: Int) {
        MDShoppingCartViewController.shoppingCart.moreProduct(index: index)
        updatePriceLabels()
    }
    
    func tableViewCellLessProduct(index: Int) {
         MDShoppingCartViewController.shoppingCart.lessProduct(index: index)
         updatePriceLabels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK - Buttons Action
  
    @IBAction func btContinueShoppingAction(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationContinueShopping"), object: nil)

    }

    @IBAction func btPayAction(_ sender: AnyObject) {
        var array = Array<String>()
        for product in MDShoppingCartViewController.shoppingCart.products
        {
            array.append(product.sku)
        }

        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "Validar compra" as NSObject,
            kFIRParameterItemID: array.map({"\($0)"}).joined(separator: ",") as NSObject
            ])
        
        if(MDShoppingCartViewController.shoppingCart.products.count > 0)
        {
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationPay"), object: nil)
        }

    }
    
    @IBAction func cleanCart(_ sender: Any) {
        MDShoppingCartViewController.shoppingCart.deleteAllProduct()
        tableView.reloadData()
        updatePriceLabels()

    }
    
    
    func updatePriceLabels()  {
        if(MDShoppingCartViewController.shoppingCart.totalCencosud != Float(0))
        {
            lbTotalPrice.text = String.localizedStringWithFormat(kFormatPrice, MDShoppingCartViewController.shoppingCart.totalCencosud).replacingOccurrences(of:",", with: ".")
            lbTotalPriceHeader.text =  String.localizedStringWithFormat("SubTotal: $ %.00f", MDShoppingCartViewController.shoppingCart.total).replacingOccurrences(of: ",", with: ".")

        }
        else
        {
            lbTotalPriceText.text = "SubTotal: "
            lbTotalPrice.text =  String.localizedStringWithFormat(kFormatPrice, MDShoppingCartViewController.shoppingCart.total).replacingOccurrences(of:",", with: ".")
            lbTotalPriceHeader.isHidden = true            
        }
        
        if(MDShoppingCartViewController.shoppingCart.products.count > 1 || MDShoppingCartViewController.shoppingCart.products.count == 0)
        {
            lbQuantityProducts.text = String(MDShoppingCartViewController.shoppingCart.products.count) + " Productos"
        }
        else
        {
            lbQuantityProducts.text = String(MDShoppingCartViewController.shoppingCart.products.count) + " Producto"
        }
        
        if(MDShoppingCartViewController.shoppingCart.products.count == 0)
        {
            btContinueShopping.layer.borderWidth = 0
            btContinueShopping.backgroundColor = COLOR_RED
            btContinueShopping.setTitleColor(UIColor.white, for: .normal)
            btContinueShopping.layer.cornerRadius = kCornerRadiusButton
            
            btPay.layer.borderColor = COLOR_GRAY_LIGHT.cgColor
            btPay.layer.borderWidth = 1
            btPay.setTitleColor(COLOR_GRAY_LIGHT, for: .disabled)
            btPay.backgroundColor = UIColor.white
            btPay.layer.cornerRadius = kCornerRadiusButton
            btPay.isEnabled = false
            
            imgShoppingCart.image = UIImage.init(named: "gris_shopping_cart_filled")
            lbTotalPrice.textColor = COLOR_GRAY_LIGHT
            lbQuantityProducts.textColor = COLOR_GRAY_LIGHT
            
            viewEmptyCart.isHidden = false

        }
        
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
