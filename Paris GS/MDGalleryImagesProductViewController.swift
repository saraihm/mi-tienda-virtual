//
//  MDGalleryImagesProductViewController.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 28-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
import WebKit

class MDGalleryImagesProductViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imagesProduct = Array<String>()
    var imageViews = Array<UIImageView>()
    var pageControl : UIPageControl!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var page = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.addLogoToNavegationItem(viewController: self)
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.tag = 100
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false
        self.configurePageControl(images: imagesProduct)
        self.setImageToScrollview(images: imagesProduct)
 
                // Do any additional setup after loading the view.
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func setImageToScrollview(images: Array<String>) {
        scrollView.contentSize = CGSize(width:self.view.frame.width * CGFloat.init(images.count), height: self.view.frame.height-66)
        
        for index in 0...images.count-1 {
            let scrollImage = UIScrollView.init(frame: CGRect(x:self.view.frame.width * CGFloat.init(index), y:0, width:self.view.frame.width, height:self.view.frame.height-66))
            let imageView = UIImageView.init(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height-66))
            scrollImage.minimumZoomScale = 1.0
            scrollImage.maximumZoomScale =  6.0
            scrollImage.delegate = self
            scrollImage.tag = index
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.doubleTapZoom(gesture:)))
            tapGesture.numberOfTapsRequired = 2
            scrollImage.addGestureRecognizer(tapGesture)
            
            var urlImage = images[index]
            let sizeWidhImage = "?wid=" + String(describing: Int(self.view.frame.height-66))
            let sizeHeightImage = "&hei=" + String(describing: Int(self.view.frame.height-66))
            urlImage = urlImage + sizeWidhImage + sizeHeightImage
            imageView.sd_setImage(with: URL.init(string: urlImage), placeholderImage:  UIImage.init(named: "cargando"))
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            scrollImage.addSubview(imageView)
            scrollView.addSubview(scrollImage)
        }
/*
            for index in 0...images.count-1 {
                let webView = WKWebView()
                webView.frame = CGRect(x:self.view.frame.width * CGFloat.init(index), y:0, width:self.view.frame.width, height:self.view.frame.height-66)
                var urlImage = images[index]
                urlImage = urlImage.replacingOccurrences(of: "?extendN=.2,.3,.2,.3", with: "")
                let sizeWidhImage = "?wid=" + String(describing: Int(self.view.frame.height-66))
                let sizeHeightImage = "&hei=" + String(describing: Int(self.view.frame.height-66))
                urlImage = urlImage + sizeWidhImage + sizeHeightImage
                let url = NSURLRequest(url: NSURL(string: urlImage)! as URL)
                webView.load(url as URLRequest)
                webView.contentMode = .scaleAspectFill
                scrollView.addSubview(webView)

            }
        */
         scrollView.scrollRectToVisible(CGRect(x: self.view.frame.width * CGFloat(page), y: 0, width: self.view.frame.width, height: self.view.frame.height-66), animated: true)
    }
    
    
    func configurePageControl(images: Array<String>) {
        // The total number of pages that are available is based on how many available colors we have.
        if(self.pageControl != nil)
        {
            self.pageControl.removeFromSuperview()
        }
        self.pageControl = UIPageControl.init(frame: CGRect(x:self.view.frame.origin.x , y:self.view.frame.size.height - 66, width:self.view.frame.size.width, height:30))
        
        self.pageControl.addTarget(self, action: #selector(MDProductDetailViewController.changePage), for: UIControlEvents.valueChanged)
        self.pageControl.numberOfPages = images.count
        self.pageControl.currentPage = page
        self.pageControl.pageIndicatorTintColor = UIColor.groupTableViewBackground
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
        
    }
    
    func changePage() -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.tag == 100)
        {
           
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            appDelegate.sendInstructionToParisTV(instruction: ["action": "changeImage" as AnyObject, "token": MDSession.UUIDAppleTV as AnyObject, "page": "ProductDetails" as AnyObject, "index": pageNumber as AnyObject])
            pageControl.currentPage = Int(pageNumber)
            
        }

    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if(scrollView.tag == 100)
        {
            return nil
        }
        return imageViews[scrollView.tag]
    }
    
    func doubleTapZoom(gesture: UITapGestureRecognizer)  {
        let scrollView = gesture.view as! UIScrollView
        if(scrollView.zoomScale > scrollView.minimumZoomScale)
        {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else
        {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }


    }
  
        
       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
