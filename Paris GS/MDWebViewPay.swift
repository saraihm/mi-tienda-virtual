//
//  MDWebViewPay.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 19-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import WebKit

class MDWebViewPay: UIViewController, WKNavigationDelegate, ValidateExperienceProtocol {
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    var progressView: UIProgressView!
    var webView: WKWebView?
    var pagesLoaded = 0
    var index = 0
    var firstLoad = true
    var loading: MDLoadingView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var backPress = false

    
   /* override func loadView() {
        super.loadView()
        
        self.webView = WKWebView()
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView()
        /*
         var libraryPath : String = FileManager().urls(for: .libraryDirectory, in: .userDomainMask).first!.path
         libraryPath += "/Cookies"
         do {
         try FileManager.default.removeItem(atPath: libraryPath)
         } catch {
         print("error")
         }
         URLCache.shared.removeAllCachedResponses()
         */
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 20)
        // progressView.sizeToFit()
        progressView.setProgress(0, animated: false)
        progressView.progressTintColor = COLOR_BLUE_LIGHT
        self.view.addSubview(progressView)
        
        self.navigationItem.addLogoToNavegationItem(viewController: self)
        self.navigationItem.addRefreshWebView(viewController: self)
        
        let urlString = kURLAddProductShoppingCartStart + "partNumber=" + MDSession.sales_code + "&quantity=1" + kURLAddProductShoppingCartEnd
        print(urlString)
        let url = URLRequest(url:  URL(string: urlString)!)
        
        
        //    let url = URLRequest(url: URL(string: "http://www.facebook.com")!)
        
        DispatchQueue.main.async {
            self.webView!.load(url)
        }
        webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView?.navigationDelegate = self
        webView?.scrollView.isDirectionalLockEnabled = true
        
            self.navigationItem.hidesBackButton = true
       // self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back")
       // self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
       // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        
        
    }
    
    func back() {
       
        if(backPress == false)
        {
            if(loading == nil)
            {
                loading = MDLoadingView.init(frame: self.view.bounds)
            }
            
            loading.starLoding(inView: self.view)

            self.backPress = true
            let surveysManager = MDSurveysManager()
            surveysManager.getSurveysSummary { (error:Bool) in
                if(self.loading != nil)
                {
                    self.loading.stopLoding()
                }
                
                if(!error)
                {
                    let validateExperience = MDValidateExperiencePopUpController()
                    validateExperience.delegate = self
                    validateExperience.surveysManager = surveysManager
                    validateExperience.modalPresentationStyle = .overCurrentContext
                    validateExperience.modalTransitionStyle = .crossDissolve
                    self.present(validateExperience, animated: true, completion: nil)
                }
                else
                {
                     self.backPress = false
                }
            }
        }

    }
    
    func closePopUp() {
        _ = self.navigationController?.popViewController(animated: true)
  //      MotionDisplaysApi.cancelAllRequests()
        appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])
    }
    
    func saleMade() {
      self.navigationItem.goToHome()
    }
    
    func sendedReason() {
        let image = UIImageView.init(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64))
        image.image = UIImage.init(named: "background_gracias")
        webView?.addSubview(image)
        let delayInSeconds = 4.0
  //      MotionDisplaysApi.cancelAllRequests()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            _ = self.navigationController?.popViewController(animated: true)
            self.appDelegate.sendInstructionToParisTV(instruction: ["action": "back" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "" as AnyObject])

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loading = MDLoadingView.init(frame: self.view.bounds)
        loading.starLoding(inView: self.view)
         progressView.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 20)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if(webView?.estimatedProgress == 0.1)
            {
                progressView.setProgress(Float((webView?.estimatedProgress)!), animated: false)
            }
            else
            {
                progressView.setProgress(Float((webView?.estimatedProgress)!), animated: true)
            }
            //   progressView.progress = Float((webView?.estimatedProgress)!)
            print(Float((webView?.estimatedProgress)!))
            
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func refreshPage()  {
        _ =  webView?.reload()
        
    }
    
    func nextPage()  {
        _ =  webView?.goForward()
    }
    
    func backPage()  {
        _ =  webView?.goBack()
    }
    
    
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        print("adding product to cart")
        progressView.isHidden = false
        if(loading == nil)
        {
            loading = MDLoadingView.init(frame: self.view.bounds)
            loading.starLoding(inView: self.view)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if(firstLoad)
        {
            print("product ", index, "added to cart")
            if(pagesLoaded == MDShoppingCartViewController.shoppingCart.products.count)
            {
                self.view = self.webView!
                progressView.isHidden = true
                webView.addSubview(progressView)
                loading.stopLoding()
                loading = nil
                firstLoad = false
            }
            else
            {
                if(index < MDShoppingCartViewController.shoppingCart.products.count)
                {
                    let url = URLRequest(url: URL(string: kURLAddProductShoppingCartStart + "partNumber=" + MDShoppingCartViewController.shoppingCart.products[index].sku + "&quantity=" +  String(MDShoppingCartViewController.shoppingCart.products[index].quantity) + kURLAddProductShoppingCartEnd)!)
                    webView.load(url)
                }
                pagesLoaded = pagesLoaded+1
                index = index + 1
            }
        }
        else
        {
            loading.stopLoding()
            loading = nil
            progressView.isHidden = true
        }
    }
    
    ///Generates script to create given cookies
    public func getJSCookiesString(cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        
        
        return result
    }
    
    public func getCookiesString(cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            
            result += "\(cookie.name)=\(cookie.value); "
        }
        
        
        return result
    }
    
    deinit {
        if(loading != nil)
        {
            loading.stopLoding()
            loading = nil
        }
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if(cookie.name != "token")
                {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
        }
        URLCache.shared.removeAllCachedResponses()
        
        print("dealloc pay")
    }
    
    
    /*    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
