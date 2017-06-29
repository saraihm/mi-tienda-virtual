//
//  MDTools.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 25-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

//EndPoint
/*let kWSURL = "Falabella2/"
let kWSCategories = kWSURL + "level"
let kWSLogin = kWSURL + "login"
let kWSLogout = kWSURL + "logout"
let kWSChangePass = kWSURL + "changePass"
let kWSRecoverPass = kWSURL + "recoverPass"
let kWSProductResult = kWSURL + "productsResult"
let kWSCompareProducts = kWSURL + "productsCompare"
let kWSFilter = kWSURL + "filter"
let kWSFilterSkus = kWSURL + "filterSkus"
let kWSNewProductSearch = kWSURL + "newProductSearch"
let kWSProductInformation = kWSURL + "productInformation"
let kWSProductInformationRelated = kWSURL + "productInformationRelated"
let kWSProductInformationSimilar = kWSURL + "productInformationSimilar"*/

let kWSURL = "/"
let kWSCategories = "categories/get_category_roots"
let kWSSubCategories = "categories/get_category_children"
let kWSLogin = "sessions/login"
let kWSLogout = "sessions/logout"
let kWSRecoverPass = "users/recover_password_by_email.json"
let kWSProductResult = "products/get_product_list"
let kWSCompareProducts = "products/get_product_compare"
let kWSFilter = "filters/get_category_filters"
let kWSFilterSkus = "products/search_filters"
let kWSProductSearch = "products/search_products"
let kWSProductInformation = "products/get_product_information"
let kWSProductPrices = "products/get_web_scrapping_prices"
let kWSProductInformationRelated = "products/get_related_products"
let kWSProductInformationSimilar = "products/get_similar_products"
let kWSLinkeableDevices = "devices/get_linkable_devices"
let kWSLinkDevice = "devices/link_device"
let kWSSimulate = "environment/get_category_environment"
let kWSurverySummary = "surveys/summary"
let kWSurveryReview = "surveys/review"

let kWSNewCart =  "cart/new"
let kWSAddItemCart = "cart/add_item"
let kWSPublishCart = "cart/publish/1"
let kWSUserSalesCode = "users/username/"



//Product Detalis
let kLbPriceCencosud = "Oferta \nExclusiva"
let kLbPriceInternet = "Internet "
let kLbPriceNormal = "Normal "

let kPriceCencosud = "offer"
let kPriceInternet = "internet"
let kPriceNormal = "normal"

//WebPay

let kURLAddProductShoppingCartStart = "https://ssl.paris.cl/webapp/wcs/stores/servlet/OrderChangeServiceItemAdd?storeId=10801&catalogId=40000000629&langId=-5&orderId=.&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&"
let kURLAddProductShoppingCartEnd = "&URL=OrderCalculate%3FcalculationUsageId%3D-1%26updatePrices%3D1%26catalogId%3D40000000629%26errorViewName%3DAjaxOrderItemDisplayView%26orderId%3D.%26langId%3D-5%26storeId%3D10801%26URL%3DAjaxOrderItemDisplayView"

let kCornerRadiusButton: CGFloat = 3

let kFormatPrice = "$ %.00f"

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(MDTools.imageWithColor(color: color), for: state)
    }
}

extension UIView {
    
    struct Constants {
        static let ExternalBorderName = "externalBorder"
    }
    
    func addExternalBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = UIColor.white, externalBoderRadius: CGFloat) -> CALayer {
        let externalBorder = CALayer()
        
        externalBorder.frame = CGRect(x:-borderWidth, y:-borderWidth, width:frame.size.width + 2 * borderWidth, height:frame.size.height + 2 * borderWidth)
        externalBorder.cornerRadius = externalBoderRadius;
        externalBorder.borderColor = borderColor.cgColor
        externalBorder.borderWidth = borderWidth
        externalBorder.name = Constants.ExternalBorderName
        
        layer.insertSublayer(externalBorder, at: 0)
        layer.masksToBounds = false
        
        return externalBorder
    }
    
    func removeExternalBorders() {
        layer.sublayers?.filter() { $0.name == Constants.ExternalBorderName }.forEach() {
            $0.removeFromSuperlayer()
        }
    }
    
    func removeExternalBorder(externalBorder: CALayer) {
        guard externalBorder.name == Constants.ExternalBorderName else { return }
        externalBorder.removeFromSuperlayer()
    }
    
}

extension UIColor {
    
    
    /// Converts a hexadecimal String into a UIColor
    /// - Parameter hex: hexadecimal string
    /// - Returns: UIColor from a hexadecimal string
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: (CharacterSet.whitespacesAndNewlines as CharacterSet)).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from:cString.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor(patternImage: UIImage(named: "img_nocolor")!)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


func uniq<S: Sequence, E: Hashable>(source: S) -> [E] where E==S.Iterator.Element {
    var seen: [E:Bool] = [:]
    return source.filter { seen.updateValue(true, forKey: $0) == nil }
}



class MDTools: NSObject {
    
    static let kWSURLTest = "http://jenkins.motiondisplays.cl:3000/"
    static let kWSURLProduction = "http://paris.motiondisplays.cl:3000/"
    
    /// Adds shadow to a UIView
    /// - Parameter view: UIView where the shadow will be added
    static func addShadowTo(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize.init(width: 0, height: 5)
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.3
    }
    
    static func addShadowToCell(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.shadowOffset = CGSize.init(width: 0, height: 3)
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.3
    }
    
    
    /// Removes shadow from a UIView
    /// - Parameter view: UIView where the shadow will be removed
    static func removeShadowTo(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        view.layer.shadowRadius = 0.0
        view.layer.shadowOpacity = 0.0
    }
    
    
    /// Rounders border to a UIImageView
    /// - Parameter imageView: UIImageView where the border will be roundered
    static func rounderBorderImage(imageView: UIImageView) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = COLOR_BLUE_LIGHT.cgColor
    }
    
    
    /// Converts a UIColor into to an UIImage
    /// - Parameter color: UIColor that will be converted into a UIImage
    /// - Returns: UIImage from a UIColor
    static func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x:0.0, y:0.0, width:1.0, height:1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    
    /// Get the items of an array from a specified range
    ///
    /// - Parameters:
    ///   - array: Array where will get items from a specific range
    ///   - range: NSRange where will get items from a Array
    /// - Returns: Array with items from a specified range
    static func subArray<T>(array: [T], range: NSRange) -> [T] {
        if range.location > array.count {
            return []
        }
        return Array(array[range.location..<min(range.length, array.count)])
    }
    
    
    
    /// Sort the prices from a product to know which if the best, regular and normal, and indicate if exist offer cenconsud or not
    /// - Parameter prices: Array with the prices of the product
    /// - Returns: three MDPrice with the best, regular and normal price from a product if exist, and a boolean that indicate if exist offer cenconsud or not
    static func price(prices: Array<MDPrice>) -> (bestPrice: MDPrice, regularPrice: MDPrice?, normalPrice: MDPrice?, isCencosud: Bool) {
        
        var bestPrice: MDPrice?
        var regularPrice: MDPrice?
        var normalPrice: MDPrice?
        var isCencosud = false
        
        for price: MDPrice in prices
        {
            if(price.name == kPriceNormal)
            {
                normalPrice = MDPrice.init(bold: price.bold, name:kLbPriceNormal, value: price.value)
            }
            
            if(price.name == kPriceInternet)
            {
                regularPrice = MDPrice.init(bold: price.bold, name:kLbPriceInternet, value: price.value)
            }
            
            if(price.name == kPriceCencosud)
            {
                bestPrice = MDPrice.init(bold: price.bold, name:kLbPriceCencosud, value: price.value)
                isCencosud = true
            }
        }
        
        if(bestPrice != nil)
        {
            if(regularPrice != nil)
            {
                return (bestPrice!, regularPrice, normalPrice, isCencosud)
            }

            return (bestPrice!, normalPrice, nil, isCencosud)

        }
        else if (regularPrice != nil)
        {
           return (regularPrice!, normalPrice, nil, isCencosud)
        }
        else
        {
            return (normalPrice!, nil, nil, isCencosud)
        }
        
    }


}

