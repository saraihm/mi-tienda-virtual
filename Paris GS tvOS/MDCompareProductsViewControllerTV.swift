//
//  MDCompareProductsViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 02-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDCompareProductsViewControllerTV: UIViewController {

    @IBOutlet weak var imgCencosud2: UIImageView!
    @IBOutlet weak var imgCencosud: UIImageView!
    @IBOutlet weak var imgProduct1: UIImageView!
    @IBOutlet weak var lbPrice1: UILabel!
    @IBOutlet weak var lbTitleProduct1: UILabel!
    @IBOutlet weak var lbTitlePrice1: UILabel!
    @IBOutlet weak var lbTitlteProduct2: UILabel!
    @IBOutlet weak var lbTitlePrice2: UILabel!
    @IBOutlet weak var lbPrice2: UILabel!
    @IBOutlet weak var imgProduct2: UIImageView!
    var compareProducts = Array<MDProduct>()
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lbTitleProduct1.text =  self.compareProducts[0].name.replacingOccurrences(of:" ", with: "  ")
        lbTitlteProduct2.text =  self.compareProducts[1].name.replacingOccurrences(of:" ", with: "  ")
        

        if(compareProducts[0].image != nil)
        {
            imgProduct1.sd_setImage(with: URL.init(string: compareProducts[0].imageTv!), placeholderImage: UIImage.init(named: ""))
        }
        else
        {
            imgProduct1.image = UIImage.init(named: "no_disponible")
        }
        
        if(compareProducts[1].image != nil)
        {
            imgProduct2.sd_setImage(with: URL.init(string: compareProducts[1].imageTv!), placeholderImage: UIImage.init(named: ""))
        }
        else
        {
            imgProduct2.image = UIImage.init(named: "no_disponible")
        }
        
        let (bestPrice, _, _, isCencosud) = MDTools.price(prices: compareProducts[0].prices)
        if(isCencosud)
        {
            lbTitlePrice1.textColor = COLOR_RED
            imgCencosud.isHidden = false
        }
        lbTitlePrice1.addCharactersSpacing(spacing: 3, text: bestPrice.name)
        lbPrice1.text = bestPrice.value
        
        let (bestPrice1, _, _, isCencosud2) = MDTools.price(prices: compareProducts[1].prices)
        if(isCencosud2)
        {
            lbTitlePrice2.textColor = COLOR_RED
            imgCencosud2.isHidden = false
        }
        lbTitlePrice2.addCharactersSpacing(spacing: 3, text: bestPrice1.name)
        lbPrice2.text = bestPrice1.value
        
        // Config Paris iPad
        appDelegate = UIApplication.shared.delegate as! AppDelegate
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // oneTime = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.doInstructions), name:NSNotification.Name(rawValue: "CompareProducts"), object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    

    
    func doInstructions(_ notification: Notification)  {
       // let message = notification.object as! Dictionary<String,AnyObject>
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("MDCompareProducts is being deallocated")
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
