 //
//  MDFilterMenuViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 27-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import SDWebImage

 protocol FilterMenunDelegate: class {
    
    func filterSelectedAction()
    
}

class MDFilterMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btSortAZ: UIButton!
    @IBOutlet weak var btSortZA: UIButton!
    @IBOutlet weak var btSortHigherPrice: UIButton!
    @IBOutlet weak var btSortLowerPrice: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var visibleCollectionReusableHeaderViews: NSMapTable<AnyObject, AnyObject>!
    weak static var delegate : FilterMenunDelegate!
    
    //Variables obtained from another ViewController
    static var productsId = Array<Int>()
    static var filters = MDFilterManager()
    var filtersArray = Array<MDFilter>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        let nibHeaderFilter = UINib.init(nibName: "MDFilterHeaderCell", bundle: nil)
        let nibOptionFilter = UINib.init(nibName: "MDFilterOptionCell", bundle: nil)

        collectionView.register(nibOptionFilter, forCellWithReuseIdentifier: "optionFilterCell")
        collectionView.register(nibHeaderFilter, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerFilterCell")
        visibleCollectionReusableHeaderViews = NSMapTable.init(keyOptions: .strongMemory, valueOptions: .weakMemory)
        filtersArray = (MDFilterMenuViewController.filters.filters)
        
        btSortHigherPrice.setImage(UIImage.init(named: "bt_radiocheck"), for: .normal)
        btSortHigherPrice.setImage(UIImage.init(named: "bt_radiocheck_fill"), for: .selected)
        
        btSortLowerPrice.setImage(UIImage.init(named: "bt_radiocheck"), for: .normal)
        btSortLowerPrice.setImage(UIImage.init(named: "bt_radiocheck_fill"), for: .selected)
        
        btSortAZ.setImage(UIImage.init(named: "bt_radiocheck"), for: .normal)
        btSortAZ.setImage(UIImage.init(named: "bt_radiocheck_fill"), for: .selected)
        
        btSortZA.setImage(UIImage.init(named: "bt_radiocheck"), for: .normal)
        btSortZA.setImage(UIImage.init(named: "bt_radiocheck_fill"), for: .selected)

        
        if(MDFilterMenuViewController.filters.isSortDesc)
        {
            btSortHigherPrice.isSelected = true
        }
        else if (MDFilterMenuViewController.filters.isSortAZ)
        {
            btSortAZ.isSelected = true
        }
        else if (MDFilterMenuViewController.filters.isSortZA)
        {
            btSortZA.isSelected = true
        }

        else
        {
            btSortLowerPrice.isSelected = true

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (!(filtersArray.count > 0)) {
            return 0;
        }
        print("section: ", section);
        let filter = filtersArray[section]
        let numOptions = filter.options.count
        
        if((MDFilterMenuViewController.filters.indexPathOpen) != nil) {
            if(MDFilterMenuViewController.filters.indexPathOpen!.section == section )
            {
                return numOptions
            }
        }
        return 0;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filtersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionFilterCell", for: indexPath as IndexPath) as! MDFilterOptionCell
        
        let filter = filtersArray[indexPath.section]
        cell.iconSelected.backgroundColor = UIColor.clear
        cell.iconSelected.layer.cornerRadius = 0
        
        if(filter.options[indexPath.item].checked == true)
        {
            cell.backgroundColor = UIColor.init(red:CGFloat(207/255.0), green: CGFloat(230/255.0), blue: CGFloat(241/255.0), alpha: 1.0)
        }
        else
        {
            cell.backgroundColor = UIColor.clear
        }
        
        if(filter.options[indexPath.item].img != nil)
        {
            cell.iconSelected.sd_setImage(with: URL.init(string: filter.options[indexPath.item].img!))
            cell.iconSelected.isHidden = false
        }
        else
        {
            cell.iconSelected.isHidden = true
        }
        
        let nameOption = filter.options[indexPath.item].name
        cell.lbTitleOption.text = nameOption?.replacingOccurrences(of:" it", with: " lt")
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerFilterCell", for: indexPath as IndexPath) as! MDFilterHeaderCell
        
        header.lbTitleFilter.text = filtersArray[indexPath.section].name
        header.checked = false
        header.open = false
        
        if(MDFilterMenuViewController.filters.firstTimeOpen == false || MDFilterMenuViewController.filters.indexPathOpen != nil || indexPath.section != 0)
        {
            if(indexPath.section == MDFilterMenuViewController.filters.indexPathOpen?.section)
            {
                header.open = true
            }
            print("toggleOpenWithUserAction: false")
            header.toggleOpenWithUserAction(userAction: false) { (willOpen: Bool) in
            }
            
        }
        
        let checkCounter = filtersArray[indexPath.section].checkCounter
        
        if(checkCounter != 0)
        {
            header.checked = true
        }
        
        let headerRecognizar = MDFilterHeaderTapRecognizer(target: self, action: #selector(self.headerTapped(sender:)))
        
        headerRecognizar.indexPath = indexPath as NSIndexPath!
        headerRecognizar.recognizerType =  3
        
        header.addGestureRecognizer(headerRecognizar)
        visibleCollectionReusableHeaderViews .setObject(header, forKey: indexPath as NSIndexPath?)

        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let filter = filtersArray[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionFilterCell", for: indexPath as IndexPath)
        let option = filter.options[indexPath.item]
        
        print("OPTION CHECKED BEFORE: ", option.checked)
        
        if(option.checked == true)
        {
            MDFilterMenuViewController.filters.lastFilterErased = option.optionID
            option.checked = false
            collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
            MDFilterMenuViewController.filters.removeAnswerID(optionID: option.optionID)
        }
        else
        {
            option.checked = true
            collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: [])
            cell.isSelected = true
            print("SELECTED OPTION: ", option.optionID)
            
            //add answerID to the selected answers
            MDFilterMenuViewController.filters.addAnswerID(optionID: option.optionID)
        }
        
        print("OPTION CHECKED AFTER: ", option.checked)
        filter.options[indexPath.item] = option
        filtersArray[indexPath.section] = filter
        
         //reload filters and rebuild filters table
        self.reloadFilterAndRebuild()
        
    }
    
    func reloadFilterAndRebuild()  {
       
        let loading = MDLoadingView.init(frame: self.view.bounds)
        loading.starLoding(inView: self.view)
        if(MDFilterMenuViewController.filters.filterWithProductsId)
        {
            MDFilterMenuViewController.filters.getFiltersWith(productsID: MDFilterMenuViewController.productsId, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    self.filtersArray = (MDFilterMenuViewController.filters.filters)
                    self.collectionView.reloadData()
                }
                loading.stopLoding()
            })

        }
        else
        {
            MDFilterMenuViewController.filters.getFiltersWith(categoryId: MDSubcategoriesViewController.categoryId!, hasError: { (hasError: Bool) in
                if(hasError == false)
                {
                    self.filtersArray = (MDFilterMenuViewController.filters.filters)
                    self.collectionView.reloadData()
                }
                loading.stopLoding()
            })

        }
      
    }
    
    // MARK: - CollectionViewDelegateFlowLayout
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:collectionView.frame.size.width-15, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.size.width-15, height:40)
    }

    
    // MARK: - CollectionViewDelegate
    func headerTapped(sender: MDFilterHeaderTapRecognizer)  {
       
        print("Header tapped for index Section ", sender.indexPath.section)
        
        let header = visibleCollectionReusableHeaderViews.object(forKey: sender.indexPath) as! MDFilterHeaderCell
       
        header.toggleOpenWithUserAction(userAction: true) { (willOpen: Bool) in
            
            var sectionChanged = false
            
            if(sender.indexPath != MDFilterMenuViewController.filters.indexPathOpen && MDFilterMenuViewController.filters.indexPathOpen != nil)
            {
                print("different section open")
                sectionChanged = true
            }
            
            if(sectionChanged == true)
            {
                let oldHeader = self.visibleCollectionReusableHeaderViews.object(forKey: MDFilterMenuViewController.filters.indexPathOpen) as! MDFilterHeaderCell
                oldHeader.open = true
                oldHeader.toggleOpenWithUserAction(userAction: true, willOpen: { (Bool) in
                    
                })
            }
            
            if (willOpen) {
                self.openSection(localCurrentIndexPath: sender.indexPath, sectionChanged:sectionChanged)
            }
            else
            {
                self.closeSection(indexPath: sender.indexPath, sectionChanged:false)
            }

        }
        

    }
    
    func openSection(localCurrentIndexPath: NSIndexPath, sectionChanged: Bool) {
        print("sectionHeaderView:sectionOpened:", localCurrentIndexPath.section)
        
        let localLastIndexPath = MDFilterMenuViewController.filters.indexPathOpen
        MDFilterMenuViewController.filters.setIndexPathOpenFilter(indexPathOpen: localCurrentIndexPath)
        let currentSection = filtersArray[(localCurrentIndexPath.section)]
        
        print("SECTION OPENED: ", localCurrentIndexPath.section)
        
        if(sectionChanged == true || MDFilterMenuViewController.filters.firstTimeOpen == true)
        {
            MDFilterMenuViewController.filters.firstTimeOpen = false
        }
        
        collectionView .performBatchUpdates({
            
            /*
             Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
             */
            var indexPathsToInsert = Array<NSIndexPath>()
            
            for index in 0...currentSection.options.count-1
            {
                indexPathsToInsert.append(NSIndexPath (row: index, section: localCurrentIndexPath.section))
            }
           
            if(indexPathsToInsert.count > 0)
            {
                self.collectionView.insertItems(at: indexPathsToInsert as [IndexPath])

            }
            
            if(sectionChanged == true && localLastIndexPath != nil)
            {
                self.closeSection(indexPath: localLastIndexPath!, sectionChanged: true)
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
                MDFilterMenuViewController.filters.setIndexPathOpenFilter(indexPathOpen: nil)
                MDFilterMenuViewController.filters.firstTimeOpen = true
            }
           
            
        }) { (Bool) in
            
        }

    }
    
    
    @IBAction func filterAction(_ sender: AnyObject) {
        
        MDFilterMenuViewController.delegate.filterSelectedAction()
    }
    
    //MARK: - Buttons Action
    @IBAction func sortForLessPrices(_ sender: AnyObject) {

        (sender as! UIButton).isSelected = true
        btSortAZ.isSelected = false
        btSortZA.isSelected = false
        btSortHigherPrice.isSelected = false
        
        MDFilterMenuViewController.filters.isSortDesc = false
        MDFilterMenuViewController.filters.isSortAsc = true
        MDFilterMenuViewController.filters.isSortAZ = false
        MDFilterMenuViewController.filters.isSortZA = false
      
        self.reloadFilterAndRebuild()
    }

    @IBAction func sortForHighetPrice(_ sender: AnyObject) {

        (sender as! UIButton).isSelected = true
        btSortAZ.isSelected = false
        btSortZA.isSelected = false
        btSortLowerPrice.isSelected = false
        
        MDFilterMenuViewController.filters.isSortAZ = false
        MDFilterMenuViewController.filters.isSortZA = false
        MDFilterMenuViewController.filters.isSortAsc = false
        MDFilterMenuViewController.filters.isSortDesc = true

        self.reloadFilterAndRebuild()
    }
    
    @IBAction func sortAtoZ(_ sender: AnyObject) {
        (sender as! UIButton).isSelected = true
        btSortZA.isSelected = false
        btSortHigherPrice.isSelected = false
        btSortLowerPrice.isSelected = false
        
        MDFilterMenuViewController.filters.isSortAZ = true
        MDFilterMenuViewController.filters.isSortZA = false
        MDFilterMenuViewController.filters.isSortAsc = false
        MDFilterMenuViewController.filters.isSortDesc = false
        
        self.reloadFilterAndRebuild()

    }

    @IBAction func sortZtoA(_ sender: AnyObject) {
        (sender as! UIButton).isSelected = true
        btSortAZ.isSelected = false
        btSortHigherPrice.isSelected = false
        btSortLowerPrice.isSelected = false
        
        MDFilterMenuViewController.filters.isSortZA = true
        MDFilterMenuViewController.filters.isSortAZ = false
        MDFilterMenuViewController.filters.isSortAsc = false
        MDFilterMenuViewController.filters.isSortDesc = false
        
        self.reloadFilterAndRebuild()
    }
    
    deinit {
        
        print("MDFilterMenuViewController is being deallocated")
        
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
