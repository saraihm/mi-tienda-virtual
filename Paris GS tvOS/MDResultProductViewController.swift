//
//  MDResultProductViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 31-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

extension UILabel {
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}

//Product Detalis
//let kLbPriceCencosud = "Oferta"
//let kLbPriceInternet = "Internet"
//let kLbPriceNormal = "Normal"

//let kPriceCencosud = "offer"
//let kPriceInternet = "internet"
//let kPriceNormal = "normal"

class MDResultProductViewController: UIViewController, SwipeViewDataSource, SwipeViewDelegate{
    
    var swipe: SwipeView!
    var timer: Timer!
    var lastIndex = 0
    var index = 0
    var remmemberIndex = 0
    var products = Array<MDProduct>()
    var appDelegate: AppDelegate!
    var compareProducts = false
    let timeInterval = 4.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        swipe = SwipeView.init(frame: CGRect(x:0, y:0, width:self.view.frame.size.height, height:self.view.frame.size.width))
        swipe.isWrapEnabled = true
        swipe.isPagingEnabled = true
        swipe.decelerationRate = 5.0
        swipe.delegate = self
        swipe.dataSource = self
        self.view.addSubview(swipe)
        
    }
    
    func loadProducts(notification: NSNotification) {
        let message = notification.object as! Dictionary<String,AnyObject>
        if(message["action"] as! String == "loadProducts")
        {
            if(timer != nil)
            {
                timer.invalidate()
                timer = nil
            }
           
            let dataJson = message["products"]
            let json = JSON(dataJson!)
            let data = json["data"].dictionary
            
            if(data == nil)
            {
                print("ERROR ON DATA")
            }
            else
            {
                for product: Any in data!["products"]!.arrayObject!
                {
                    let product = MDProduct.init(attributes: product as! Dictionary<String, AnyObject>)
                    if(product != nil)
                    {
                        self.products.append(product!)
                    }
                }
            }

            if(products.count < 8)
            {
                lastIndex = products.count
            }
            else
            {
                lastIndex = 8
            }

            if(swipe != nil)
            {
                swipe.reloadData()
            }
            
            if(timer == nil)
            {
                timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            }
            
        }
        if(message["action"] as! String == "updateProduct")
        {
            
            let dataJson = message["data"]
            let json = JSON(dataJson!)
            let data = json["data"].dictionary
            
            if(data == nil)
            {
                print("ERROR ON DATA")
            }
            else
            {
                for product: Any in data!["products"]!.arrayObject!
                {
                    let product = MDProduct.init(attributes: product as! Dictionary<String, AnyObject>)
                    if(product != nil)
                    {
                        self.products[message["index"] as! Int] = product!
                        break
                    }
                }
                
            }
            
            swipe.reloadItem(at: message["index"] as! Int)
            
        }
        
        if(message["action"] as! String == "indexCollectionView")
        {
            index = message["firstProductIndexShow"] as! Int
            lastIndex = message["lastProductIndexShow"] as! Int
            remmemberIndex = index
        }
        
        if(message["action"] as! String == "removeProducts")
        {
            if(timer != nil)
            {
                timer.invalidate()
                timer = nil

            }
            
            if(swipe != nil)
            {
                index = 0
                remmemberIndex = 0
                lastIndex = 0
                products.removeAll()
                swipe.reloadData()
            }
            
        }
        
        if(message["action"] as! String == "compareProdcuts")
        {
            let dataJson = message["products"]
            let json = JSON(dataJson!)
            let data = json["data"].dictionary
            
            if(data == nil)
            {
                print("ERROR ON DATA")
            }
            else
            {
                var compareProducts = Array<MDProduct>()
                let productShortDescription = data!["products"]?.array
                
                for productNew: JSON in productShortDescription!
                {
                    let product = MDProduct.init(attributes: productNew.dictionaryObject! as Dictionary<String, AnyObject>)
                    compareProducts.append(product!)
                }
                
                if(compareProducts.count != 0)
                {
                    let viewController = MDCompareProductsViewControllerTV()
                    viewController.compareProducts = compareProducts
                    self.compareProducts = true
                    self.navigationController?.pushViewController(viewController, animated: true)

                }
            }
    
        }
        if(message["action"] as! String == "productDetails")
        {
            self.compareProducts = true
            let viewController = MDProductDetailsViewController()
            viewController.product = products[message["index"] as! Int]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadProducts), name:NSNotification.Name(rawValue: "ResultProducts"), object: nil)

        if(timer == nil)
        {
            timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        if(timer != nil)
        {
            timer.invalidate()
            timer = nil
        }
        
        if(!compareProducts)
        {
            index = 0
            remmemberIndex = 0
            lastIndex = 0
        }
        
    }
    
    func runTimedCode() {
        swipe.scrollToItem(at: index, duration: 0.5)
        appDelegate.server.sendObject(["index": index as AnyObject!, "token": MDSession.tokenSession as AnyObject!] as Dictionary<String, AnyObject> as NSCoding!)
        
        if(lastIndex+remmemberIndex != 1)
        {
            index = index + 1
            if(index == lastIndex+remmemberIndex)
            {
                index = remmemberIndex
            }
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfItems(in swipeView: SwipeView!) -> Int {
        return self.products.count
    }
    
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var viewItem = view
        var viewProduct: MDProductView
       
        
        if(viewItem == nil)
        {
            viewItem = UIView.init(frame: CGRect(x:0, y:0, width:self.view.frame.size.width, height:self.view.frame.size.height))
            
            viewProduct = MDProductView.init(frame: (viewItem?.frame)!)
            viewProduct.tag = 1
            viewItem?.addSubview(viewProduct)
 
        }
        
        let (bestPrice, regularPrice, normalPrice, isCencosud) = MDTools.price(prices: products[index].prices)
       
        viewProduct = viewItem?.viewWithTag(1) as! MDProductView
        viewProduct.lbTitleBestPrice.isHidden = false
        viewProduct.lbBestPrice.isHidden = false
        viewProduct.lbTitleNormalPrice.isHidden = false
        viewProduct.lbNormalPrice.isHidden = false
        viewProduct.lbDiscount.isHidden = false
        viewProduct.lbPriceAfterDiscount.isHidden = false
        viewProduct.lbPriceBeforeDiscount.isHidden = false
        
        if(isCencosud)
        {
            viewProduct.lbTitleBestPrice.textColor = COLOR_RED
            viewProduct.imgCencosud.isHidden = false
        }
        else
        {
            viewProduct.lbTitleBestPrice.textColor = COLOR_BLUE
            viewProduct.imgCencosud.isHidden = true
        }

        viewProduct.lbDescription.text = products[index].name.replacingOccurrences(of:" ", with: "  ")
        
        if(products[index].imageTv != nil)
        {
            viewProduct.imageProduct.sd_setImage(with: URL.init(string: products[index].imageTv!), placeholderImage: UIImage.init(named: ""))
        }
        else
        {
            viewProduct.imageProduct.image = UIImage.init(named: "no_disponible")
        }
        
    /*    if(products[index].discount != nil && products[index].discount != "-" && products[index].discount != "")
        {
            viewProduct.lbDiscount.text = products[index].discount
            viewProduct.lbPriceAfterDiscount.text = bestPrice.value
            
            if(regularPrice != nil)
            {
                viewProduct.lbPriceBeforeDiscount.text = "Antes:  " + (regularPrice?.value)!
            }
            else if(normalPrice != nil)
            {
                viewProduct.lbPriceBeforeDiscount.text = "Antes:  " + ((normalPrice?.value)!)!
            }
            else
            {
                viewProduct.lbPriceBeforeDiscount.isHidden = true
            }
            
            viewProduct.lbTitleBestPrice.isHidden = true
            viewProduct.lbBestPrice.isHidden = true
            viewProduct.lbTitleNormalPrice.isHidden = true
            viewProduct.lbNormalPrice.isHidden = true
        }
        else
        {*/
            viewProduct.lbTitleBestPrice.text = bestPrice.name
            viewProduct.lbBestPrice.text = bestPrice.value
            
            if(regularPrice != nil)
            {
                viewProduct.lbNormalPrice.text = regularPrice?.value
                viewProduct.lbTitleNormalPrice.addCharactersSpacing(spacing: 3, text: (regularPrice?.name)!)
            }
            else if(normalPrice != nil)
            {
                viewProduct.lbNormalPrice.text = normalPrice?.value
                viewProduct.lbTitleNormalPrice.addCharactersSpacing(spacing: 3, text: (normalPrice?.name)!)
            }
            else
            {
                viewProduct.lbNormalPrice.isHidden = true
                viewProduct.lbTitleNormalPrice.isHidden = true
            }

            viewProduct.lbDiscount.isHidden = true
            viewProduct.lbPriceAfterDiscount.isHidden = true
            viewProduct.lbPriceBeforeDiscount.isHidden = true
       // }

        
        return viewItem
        
    }
    
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
          }
    
    deinit {
        print("MDResultProduct is being deallocated")
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
