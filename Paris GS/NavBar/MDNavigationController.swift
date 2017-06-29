//
//  MDNavigationController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit


extension UINavigationItem {
    func addLogoToNavegationItem(viewController: UIViewController)  {
        
        let container = UIView.init(frame: CGRect(x:0, y:0, width:42, height:42))
        let image = UIImageView.init(frame: CGRect(x:0, y:0, width:42, height:42))
        image.tag = 1
        image.image = UIImage.init(named: "Logo_Paris_nav")
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UILongPressGestureRecognizer.init(target: viewController, action: #selector(viewController.closeSesion(sender:))))
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.goToHome)))
        
        container.addSubview(image)
        
        // set the nav bar's titleview comparator button
        self.titleView = container;       
    }
    
    func addCategoriesToNavegationItem(viewController: UIViewController)  {
       
        self.leftBarButtonItems?.removeAll()
        // create a button and add it to the container
        let container = UIView.init(frame: CGRect(x:0, y:0, width:120, height:30))
        let buttonCategories = UIButton.init(frame: CGRect(x:0, y:0, width:120, height:30))
        buttonCategories.titleLabel?.font = UIFont.init(name: "AzoSans", size: 15)
        buttonCategories.setTitle("Categorías ⌄", for: .normal)
        buttonCategories.setTitleColor(UIColor.white, for: .normal)
        buttonCategories.layer.borderWidth = 1
        buttonCategories.layer.borderColor = UIColor.white.cgColor
        buttonCategories.setBackgroundColor(color: COLOR_BLUE, forUIControlState: .normal)
        buttonCategories.setBackgroundColor(color: COLOR_BLUE, forUIControlState: .highlighted)
        buttonCategories.addTarget(viewController, action: #selector(viewController.showCategories), for: .touchUpInside)
        buttonCategories.layer.cornerRadius = kCornerRadiusButton
        container.addSubview(buttonCategories)
        
        let leftView = UIBarButtonItem.init(customView: container)

        self.leftItemsSupplementBackButton = true
        self.setLeftBarButton(leftView, animated: true)
    }
    
    func addItemsRightToNavegationItem(withBtFilter: Bool, viewController: UIViewController)  {
        
        self.rightBarButtonItems?.removeAll()
        
        let height = CGFloat.init(integerLiteral: 31)
        let width = CGFloat.init(integerLiteral: 31)
        let space = CGFloat.init(integerLiteral: 31)+45
        let widthBtFilter = CGFloat.init(integerLiteral: 80)
        
        // create a button and add it to the container
        let container = UIView.init(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width/3-25, height: height))
        
        let btShoppingCart = MIBadgeButton.init(frame: CGRect(x:container.frame.size.width-width, y:0, width:width, height:height))
        btShoppingCart.setBackgroundImage(UIImage.init(named: "ic_shopping_cart"), for: .normal)
        btShoppingCart.addTarget(viewController, action: #selector(viewController.setMenuShoppingCart(sender:)), for: .touchUpInside)
        btShoppingCart.tag = 4
        btShoppingCart.badgeBackgroundColor = COLOR_RED
        btShoppingCart.badgeTextColor = UIColor.white
        btShoppingCart.badgeString = String(MDShoppingCartViewController.shoppingCart.products.count)
        if(MDShoppingCartViewController.shoppingCart.products.count == 0)
        {
            btShoppingCart.badgeLabel.isHidden = true
        }
       
        container.addSubview(btShoppingCart)
        
        let btSearchProduct = UIButton.init(frame: CGRect(x:container.frame.size.width-width-space, y:0, width:width+2, height:height))
        btSearchProduct.setBackgroundImage(UIImage.init(named: "ic_search"), for: .normal)
        btSearchProduct.tag = 3
        container.addSubview(btSearchProduct)
        
        if(viewController.isKind(of:MDProductsViewController.self))
        {
            let controller = viewController as! MDProductsViewController
            btSearchProduct.addTarget(viewController, action: #selector(controller.showSearchBar), for: .touchUpInside)
        }
        else if(viewController.isKind(of:MDCategoriesViewController.self))
        {
            let controller = viewController as! MDCategoriesViewController
            btSearchProduct.addTarget(viewController, action: #selector(controller.showSearchBar), for: .touchUpInside)
        }
        else  if(viewController.isKind(of:MDSubcategoriesViewController.self))
        {
            let controller = viewController as! MDSubcategoriesViewController
            btSearchProduct.addTarget(viewController, action: #selector(controller.showSearchBar), for: .touchUpInside)
        }
        else  if(viewController.isKind(of:MDProductDetailViewController.self))
        {
            let controller = viewController as! MDProductDetailViewController
            btSearchProduct.addTarget(viewController, action: #selector(controller.showSearchBar), for: .touchUpInside)
        }
        
        let btHome = UIButton.init(frame: CGRect(x:container.frame.size.width-width-2-space*2, y:0, width:width+5, height:height))
        btHome.setBackgroundImage(UIImage.init(named: "ic_home"), for: .normal)
        btHome.tag = 2
        btHome.addTarget(self, action: #selector(self.goToHome), for: .touchUpInside)
        container.addSubview(btHome)

        
        if(withBtFilter)
        {
            let buttonFilter = UIButton.init(frame: CGRect(x:0, y:0, width:widthBtFilter, height:height))
            buttonFilter.titleLabel?.font = UIFont.init(name: "AzoSans", size: 15)
            buttonFilter.setTitle("Filtro", for: .normal)
            buttonFilter.layer.borderWidth = 1
            buttonFilter.layer.borderColor = UIColor.white.cgColor
            buttonFilter.setTitleColor(UIColor.white, for: .normal)
            buttonFilter.setBackgroundColor(color: COLOR_BLUE, forUIControlState: .normal)
            buttonFilter.setBackgroundColor(color: UIColor.white, forUIControlState: .selected)
            buttonFilter.setTitleColor(COLOR_BLUE, for: .selected)
            buttonFilter.setBackgroundColor(color: UIColor.white, forUIControlState: .highlighted)
            buttonFilter.setTitleColor(COLOR_BLUE, for: .highlighted)
            buttonFilter.tag = 1
            buttonFilter.layer.cornerRadius = kCornerRadiusButton
            
            buttonFilter.addTarget(viewController, action: #selector(viewController.setMenuFilter(sender:)), for: .touchUpInside)
            container.addSubview(buttonFilter)
        }

        
        let rightView = UIBarButtonItem.init(customView: container)
        self.setRightBarButton(rightView, animated: false)

    }
    
    func addSearchBar(searchBar: UISearchBar, viewController: UIViewController)  {
        let container = UIView.init(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width/2+320, height:42))
        searchBar.frame = CGRect(x:40, y:0, width:580, height:42)
        container.addSubview(searchBar)
        
        let btCancelSearch = UIButton.init(frame: CGRect(x:640, y:42/2-35/2, width:80, height:35))
        btCancelSearch.titleLabel?.font = UIFont.init(name: "AzoSans", size: 15)
        btCancelSearch.setTitle("Cancelar", for: .normal)
        btCancelSearch.layer.borderWidth = 1
        btCancelSearch.layer.borderColor = UIColor.white.cgColor
        btCancelSearch.setTitleColor(UIColor.white, for: .normal)
        btCancelSearch.setBackgroundColor(color: COLOR_BLUE, forUIControlState: .normal)
        btCancelSearch.setTitleColor(UIColor.white, for: .highlighted)
        btCancelSearch.setBackgroundColor(color: COLOR_BLUE, forUIControlState: .highlighted)
        btCancelSearch.layer.cornerRadius = kCornerRadiusButton
        
        if(viewController.isKind(of:MDProductsViewController.self))
        {
            let controller = viewController as! MDProductsViewController
            btCancelSearch.addTarget(controller, action: #selector(controller.cancelSearchButton), for: .touchUpInside)
        }
        else if(viewController.isKind(of:MDCategoriesViewController.self))
        {
            let controller = viewController as! MDCategoriesViewController
            btCancelSearch.addTarget(controller, action: #selector(controller.cancelSearchButton), for: .touchUpInside)
        }
        else  if(viewController.isKind(of:MDSubcategoriesViewController.self))
        {
            let controller = viewController as! MDSubcategoriesViewController
            btCancelSearch.addTarget(controller, action: #selector(controller.cancelSearchButton), for: .touchUpInside)
        }
        else  if(viewController.isKind(of:MDProductDetailViewController.self))
        {
            let controller = viewController as! MDProductDetailViewController
            btCancelSearch.addTarget(controller, action: #selector(controller.cancelSearchButton), for: .touchUpInside)
        }

        
        container.addSubview(btCancelSearch)

        let rightiew = UIBarButtonItem.init(customView: container)
        

        self.leftBarButtonItems?.removeAll()
        self.rightBarButtonItems?.removeAll()
       
        UIView.animate(withDuration: 0.5, animations: {
            self.setRightBarButton(rightiew, animated: true)
            }, completion:  { finished in
                searchBar.becomeFirstResponder()
        })
    }
    
    func addRefreshWebView(viewController: UIViewController)  {
        self.rightBarButtonItems?.removeAll()
        
        let height = CGFloat.init(integerLiteral: 31)
        let width = CGFloat.init(integerLiteral: 31)
        let space = CGFloat.init(integerLiteral: 31)+45
        
        // create a button and add it to the container
        let container = UIView.init(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width/3-25, height: height))
        
        let backButton = UIButton.init(frame: CGRect(x:container.frame.size.width-width, y:10, width:28, height:16))
        backButton.setBackgroundImage(UIImage.init(named: "arrows_long_right"), for: .normal)
        backButton.tag = 1
        backButton.addGestureRecognizer(UITapGestureRecognizer.init(target: viewController as! MDWebViewPay, action: #selector((viewController as! MDWebViewPay).nextPage)))
        container.addSubview(backButton)
        
        let image = UIImageView.init(frame: CGRect(x:container.frame.size.width-width-space, y:0, width:31, height:31))
        image.tag = 2
        image.image = UIImage.init(named: "recurring_appointment")
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer.init(target: viewController as! MDWebViewPay, action: #selector((viewController as! MDWebViewPay).refreshPage)))
        
         container.addSubview(image)

        let nextPageButton = UIButton.init(frame: CGRect(x:container.frame.size.width-width-2-space*2, y:10, width:28, height:16))
        nextPageButton.setBackgroundImage(UIImage.init(named: "arrows_long_left"), for: .normal)
        nextPageButton.tag = 3
        nextPageButton.addGestureRecognizer(UITapGestureRecognizer.init(target: viewController as! MDWebViewPay, action: #selector((viewController as! MDWebViewPay).backPage)))

        container.addSubview(nextPageButton)
        
        let rightView = UIBarButtonItem.init(customView: container)
        self.setRightBarButton(rightView, animated: false)
    }
    
    func goToHome() {
        MotionDisplaysApi.cancelAllRequests()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(!(appDelegate.navigationController.visibleViewController is MDCategoriesViewController))
        {
            if(appDelegate.navigationController.visibleViewController is MDProductsViewController)
            {
                (appDelegate.navigationController.visibleViewController as! MDProductsViewController).isFilter = false
            }
            appDelegate.navigationController = ENSideMenuNavigationController.init(menuViewController: MDFilterMenuViewController(), contentViewController: MDCategoriesViewController())
          // appDelegate.navigationController.view.layer.add(transition, forKey: nil)
             appDelegate.window?.rootViewController = appDelegate.navigationController
            appDelegate.navigationController.popToRootViewController(animated: true)

            
            appDelegate.sendInstructionToParisTV(instruction: ["action": "goToHome" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])

        }
    }
    
}

extension UIViewController
{
    func showCategories(sender: UIButton)  {
        
        let viewController =  MDCategoriesMenuViewController()
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize(width:250, height:45*MDCategoriesManager.categories.count)
        self.navigationController?.present(viewController, animated: true, completion: nil)
        let  popController  = viewController.popoverPresentationController
        popController?.permittedArrowDirections = .any
        popController?.sourceView = sender
        popController?.sourceRect = CGRect(x:0, y:0, width:sender.frame.size.width, height:sender.frame.size.height)
        
    }
}


class MDNavigationController: UINavigationController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
