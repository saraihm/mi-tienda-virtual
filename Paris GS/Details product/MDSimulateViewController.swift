//
//  MDSimulateViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 11-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSimulateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var pageControlWall: UIPageControl!
    @IBOutlet weak var pageControlFloor: UIPageControl!
    @IBOutlet var viewPopUp: UIView!
    @IBOutlet weak var collectionViewFloor: UICollectionView!
    @IBOutlet weak var collectionViewWall: UICollectionView!
    var simulateEnviroment = MDSimulateEnviroment()
    var indexSelectedFloor = 0
    var indexSelectedWall = 0
    var oneTime = false
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionViewFloor.tag = 0
        collectionViewWall.tag = 1
        collectionViewFloor.register(UINib(nibName: "MDSimulatorCell", bundle: nil), forCellWithReuseIdentifier: "simulatorCell")
        collectionViewWall.register(UINib(nibName: "MDSimulatorCell", bundle: nil), forCellWithReuseIdentifier: "simulatorCell")
        
        let width = UIScreen.main.bounds.size.width
        let heigth = UIScreen.main.bounds.size.height
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.frame = CGRect(x:0, y:0, width:width, height:heigth)
        self.viewPopUp.frame = CGRect(x:(width/2) - (width-150)/2, y:(heigth/2)-(heigth-145)/2, width: width-150, height: heigth-145)
        self.view.addSubview(viewPopUp)
        
        // Config Paris tvOS
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.pageControlFloor.numberOfPages = Int(round(Double(simulateEnviroment.floorOptions.count/5)))
        self.pageControlFloor.currentPage = 0
        self.pageControlFloor.pageIndicatorTintColor = UIColor.groupTableViewBackground
        self.pageControlFloor.currentPageIndicatorTintColor = UIColor.black
        
        self.pageControlWall.numberOfPages = Int(round(Double(simulateEnviroment.wallOptions.count/5)))
        self.pageControlWall.currentPage = 0
        self.pageControlWall.pageIndicatorTintColor = UIColor.groupTableViewBackground
        self.pageControlWall.currentPageIndicatorTintColor = UIColor.black
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.appDelegate.sendInstructionToParisTV(instruction: (["action": "changeFloor" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "image": self.simulateEnviroment.floorOptions[indexSelectedFloor].optionImage] as AnyObject) as! Dictionary<String, AnyObject>)
        
        self.appDelegate.sendInstructionToParisTV(instruction: (["action": "changeWall" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "image": self.simulateEnviroment.wallOptions[indexSelectedWall].optionImage] as AnyObject) as! Dictionary<String, AnyObject>)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeout), name: NSNotification.Name(rawValue: "AppTimeOut"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func removeView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews", collectionViewFloor.frame)
    }
    //MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0)
        {
           return self.simulateEnviroment.floorOptions.count
        }
        else
        {
            return self.simulateEnviroment.wallOptions.count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "simulatorCell", for: indexPath as IndexPath) as! MDSimulatorCell

        
        cell.image.layer.masksToBounds = true
        cell.image.layer.cornerRadius = cell.image.frame.size.width/2;
        cell.image.clipsToBounds = true
        cell.image.layer.borderColor = UIColor.black.cgColor
        cell.image.layer.borderWidth = 1
        cell.image.backgroundColor = UIColor.black

        if(collectionView.tag == 0)
        {
            cell.image.sd_setImage(with: URL.init(string: simulateEnviroment.floorOptions[indexPath.row].optionPreview), placeholderImage: UIImage.init(named: "cargando"))
            
            if(indexPath.row == indexSelectedFloor)
            {
                cell.image.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
                cell.image.layer.borderWidth = 6
                // currentCell!.image.addExternalBorder(6, borderColor: COLOR_BLUE_LIGHT,externalBoderRadius: 69)
                cell.image.layer.masksToBounds = true
                cell.image.clipsToBounds = true
                collectionViewFloor.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: [])
            }
        }
        else
        {
            cell.image.sd_setImage(with: URL.init(string: simulateEnviroment.wallOptions[indexPath.row].optionPreview), placeholderImage: UIImage.init(named: "cargando"))
            
            if(indexPath.row == indexSelectedWall)
            {
                cell.image.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
                cell.image.layer.borderWidth = 6
                // currentCell!.image.addExternalBorder(6, borderColor: COLOR_BLUE_LIGHT,externalBoderRadius: 69)
                cell.image.layer.masksToBounds = true
                cell.image.clipsToBounds = true
                collectionViewWall.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: [])
                cell.isSelected = true


            }
        }
        
        //   cell.image.removeExternalBorders()
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        
        if(collectionView.tag == 0)
        {
            indexSelectedFloor = indexPath.row
            self.appDelegate.sendInstructionToParisTV(instruction: (["action": "changeFloor" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "image": self.simulateEnviroment.floorOptions[indexPath.row].optionImage] as AnyObject) as! Dictionary<String, AnyObject>)
        }
        else
        {
            indexSelectedWall = indexPath.row
           self.appDelegate.sendInstructionToParisTV(instruction: (["action": "changeWall" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "image": self.simulateEnviroment.wallOptions[indexPath.row].optionImage] as AnyObject) as! Dictionary<String, AnyObject>)
        }
        
        let currentCell = collectionView.cellForItem(at: indexPath as IndexPath) as? MDSimulatorCell
        if(currentCell != nil)
        {
            currentCell!.image.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
            currentCell!.image.layer.borderWidth = 6
           // currentCell!.image.addExternalBorder(6, borderColor: COLOR_BLUE_LIGHT,externalBoderRadius: 69)
            currentCell!.image.layer.masksToBounds = true
            currentCell!.image.clipsToBounds = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect cell no: \(indexPath.row) of collection view: \(collectionView.tag)")
        let currentCell = collectionView.cellForItem(at: indexPath as IndexPath) as? MDSimulatorCell
        if(currentCell != nil)
        {
            currentCell!.image.layer.masksToBounds = true
            currentCell!.image.clipsToBounds = true
            currentCell!.image.layer.borderColor = UIColor.black.cgColor
            currentCell!.image.layer.borderWidth = 1
          //  currentCell!.image.removeExternalBorders()
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:155, height:155)
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 20, 0);
    }*/
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.tag == 0)
        {
            let pageNumber = round(collectionViewFloor.contentOffset.x / collectionViewFloor.frame.size.width)
            pageControlFloor.currentPage = Int(pageNumber)
            
        }
        
        if(scrollView.tag == 1)
        {
            let pageNumber = round(collectionViewWall.contentOffset.x / collectionViewWall.frame.size.width)
            pageControlWall.currentPage = Int(pageNumber)
            
        }

        
    }
    
    
    func applicationDidTimeout()  {
        print("tiempo muerto en vista simular")
        self.dismiss(animated: false, completion: nil)
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
