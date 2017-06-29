//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

public class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol {
    
    public var sideMenu : ENSideMenu?
    public var sideMenuAnimationType : ENSideMenuAnimation = .Default
    
    
    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = COLOR_BLUE
        
    }

    public init( menuViewController: UIViewController?, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }

        if (menuViewController != nil) {
           sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menuViewController!, menuPosition:.Right)
        }
        
        view.bringSubview(toFront: navigationBar)
        sideMenu?.menuWidth = UIScreen.main.bounds.width/3
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    public func setContentViewController(contentViewController: UIViewController) {
        self.sideMenu?.hideSideMenu()
        switch sideMenuAnimationType {
        case .None:
            self.viewControllers = [contentViewController]
            break
        default:
            contentViewController.navigationItem.hidesBackButton = true
            self.setViewControllers([contentViewController], animated: true)
            break
        }
        
    }
}
