//
//  MDProductDetailsViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 07-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDProductDetailsViewController: UIViewController, SwipeViewDataSource, SwipeViewDelegate {

    @IBOutlet weak var constrainViewBlack: NSLayoutConstraint!
    @IBOutlet weak var imgCencosud: UIImageView!
    @IBOutlet weak var imgFloor: UIImageView!
    @IBOutlet weak var imgWall: UIImageView!
    @IBOutlet weak var swipe: SwipeView!
    
    @IBOutlet weak var lbPriceBeforeDiscount: UILabel!
    @IBOutlet weak var lbPriceAfterDiscount: UILabel!
    @IBOutlet weak var lbRegularPrice: UILabel!
    @IBOutlet weak var LbTitleRegularPrice: UILabel!
    @IBOutlet weak var lbDiscount: UILabel!
    @IBOutlet weak var lbNormalPrice: UILabel!
    @IBOutlet weak var lbBestPrice: UILabel!
    @IBOutlet weak var lbTitleNormalPrice: UILabel!
    @IBOutlet weak var lbTitleBestPrice: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var viewDescription: UIView!

    var product = MDProduct()
    var appDelegate: AppDelegate!
    var images = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        swipe.isWrapEnabled = true
        swipe.isPagingEnabled = true
        swipe.decelerationRate = 5.0
        swipe.delegate = self
        swipe.dataSource = self
        swipe.backgroundColor = UIColor.clear
      
        
        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(self.doInstructions), name:NSNotification.Name(rawValue: "ProductDetails"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(self.doInstructions), name:NSNotification.Name(rawValue: "ProductDetails"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func showPrices(_ bestPrice: String, titleBest: String, regularPrice: String, titleRegular: String,normalPrice: String, titleNormal: String, isCencosud: Bool)  {
        
        if(isCencosud)
        {
            lbTitleBestPrice.textColor = COLOR_RED
            imgCencosud.isHidden = false
        }
        else
        {
            lbTitleBestPrice.textColor = COLOR_BLUE
            imgCencosud.isHidden = true
        }
        
        lbTitleBestPrice.text = titleBest
        lbBestPrice.text = bestPrice
        
        if(regularPrice != "")
        {
            lbRegularPrice.text = regularPrice
            LbTitleRegularPrice.addCharactersSpacing(spacing: 3, text: titleRegular)
            
            if(normalPrice != "")
            {
                lbNormalPrice.text = normalPrice
                lbTitleNormalPrice.addCharactersSpacing(spacing: 3, text: titleNormal)
                constrainViewBlack.constant = 350
            }
            else
            {
                lbNormalPrice.text = ""
                lbTitleNormalPrice.text = ""
                constrainViewBlack.constant = 310
            }
        }
        else
        {
            lbRegularPrice.text = ""
            LbTitleRegularPrice.text = ""
        }

        /*
      
        if(product.discount != nil && product.discount != "-" && product.discount != "")
        {            
            lbDiscount.text = product.discount
            lbPriceAfterDiscount.text = bestPrice
            
            if(normalPrice != "")
            {
                lbPriceBeforeDiscount.text = "Antes:  " + normalPrice
            }
            else
            {
                lbPriceBeforeDiscount.isHidden = true
            }
            
            lbTitleBestPrice.isHidden = true
            lbBestPrice.isHidden = true
            lbTitleNormalPrice.isHidden = true
            lbNormalPrice.isHidden = true
            
        }
        else
        {
            lbTitleBestPrice.text = titleBest
            lbBestPrice.text = bestPrice
            
            if(normalPrice != "")
            {
                lbNormalPrice.text = normalPrice
                lbTitleNormalPrice.addCharactersSpacing(spacing: 3, text: titleNormal)
            }
            else
            {
                lbNormalPrice.isHidden = true
                lbTitleNormalPrice.isHidden = true
            }
            
            lbDiscount.isHidden = true
            lbPriceAfterDiscount.isHidden = true
            lbPriceBeforeDiscount.isHidden = true
        }
*/
    }
    
    func doInstructions(_ notification: Notification)  {
        let message = notification.object as! Dictionary<String,AnyObject>
        
        if(message["action"] as! String == "reloadPage")
        {
            NotificationCenter.default.removeObserver(self)
            let viewController = MDProductDetailsViewController()
            let product = MDProduct()
            product.discount = message["discount"] as? String
            viewController.product = product

            self.navigationController?.pushViewController(viewController, animated: true)
        }
        if(message["action"] as! String == "updateInfo")
        {
            lbDescription.text =  (message["description"] as? String)?.replacingOccurrences(of:" ", with: "  ")
            images.removeAll()
            
            for image in message["images"] as! Array<String>
            {
                images.append(image.replacingOccurrences(of: "https", with: "http"))
            }
            
            if(images.count == 0)
            {
                let imgProduct = UIImageView.init(frame: swipe.frame)
                imgProduct.image = UIImage.init(named: "no_disponible")
                self.view.addSubview(imgProduct)
            }
            

            swipe.reloadData()
        }
        if(message["action"] as! String == "updateImages")
        {
            images.removeAll()
            
            for image in message["images"] as! Array<String>
            {
                images.append(image.replacingOccurrences(of: "https", with: "http"))
            }
            
            swipe.reloadData()
        }
        if(message["action"] as! String == "updatePrices")
        {
            product.discount = message["discount"] as? String
            showPrices((message["bestPrice"] as? String)!, titleBest: (message["titleBestPrice"] as? String)!, regularPrice: (message["regularPrice"] as? String)!, titleRegular: (message["titleRegularPrice"] as? String)!, normalPrice: (message["normalPrice"] as? String)!, titleNormal: (message["titleNormalPrice"] as? String)!, isCencosud: (message["isCencosud"] as? Bool)!)
           
        }
        
        if(message["action"] as! String == "changeImage")
        {
            swipe.scrollToItem(at: message["index"] as! Int, duration: 1.0)
        }
        
        if(message["action"] as! String == "changeFloor")
        {
            let nameImage = (message["image"] as! String).replacingOccurrences(of: "https", with: "http")
            imgFloor.sd_setImage(with: URL.init(string: nameImage), completed: nil)
        }
        
        if(message["action"] as! String == "changeWall")
        {
            let nameImage = (message["image"] as! String).replacingOccurrences(of: "https", with: "http")
            imgWall.sd_setImage(with: URL.init(string: nameImage), completed: nil)
        }
        
        if(message["action"] as! String == "clearSimulation")
        {
            imgWall.sd_setImage(with: URL.init(string: ""), completed: nil)
            imgFloor.sd_setImage(with: URL.init(string:""), completed: nil)
        }

    }

    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return self.images.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var viewItem = view
        var imgProduct: UIImageView
        
        if(viewItem == nil)
        {
            viewItem = UIView.init(frame:CGRect(x: 0, y:0 , width:self.swipe.frame.size.width, height: self.swipe.frame.size.height))
            print(self.swipe.frame)
            imgProduct = UIImageView.init(frame:(viewItem?.frame)!)

            imgProduct.tag = 1
            imgProduct.backgroundColor = UIColor.clear           
            viewItem?.addSubview(imgProduct)
        }
        
        imgProduct = viewItem?.viewWithTag(1) as! UIImageView
        print(imgProduct.frame)
        imgProduct.sd_setImage(with: URL.init(string: images[index]), placeholderImage: UIImage.init(named: ""))
        
        return viewItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("MDProducDetails is being deallocated")
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
