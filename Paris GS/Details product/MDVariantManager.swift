//
//  MDVariantManager.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 30-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDVariantManager: NSObject {

    var variants = Array<MDVariant>()
    var dataSource = Array<MDVariatnDataSource>()
    
    init(variants: Array<MDVariant>) {
        self.variants = variants
        var variantDataSourceColor: MDVariatnDataSource!
        variantDataSourceColor = MDVariatnDataSource.init(type: "Color")
        variantDataSourceColor.setDataSource(self.variants, setSelection: true, withSimulation: false)
        var variantDataSourceTalla: MDVariatnDataSource!
        variantDataSourceTalla = MDVariatnDataSource.init(type: "Talla")
        variantDataSourceTalla.setDataSource(self.variants, setSelection: false, withSimulation: false)
        if(variantDataSourceColor.dataSource.count > 0)
        {
            dataSource.append(variantDataSourceColor)
        }
        if(variantDataSourceTalla.dataSource.count > 0)
        {
            dataSource.append(variantDataSourceTalla)
        }
    }
    /*
    func currentVariant() -> MDVariant {
        if(dataSource.count > 1)
        {
            var dataPropertyColor = dataSource[0]
            var dataPropertyTalla = dataSource[1]
            if(dataPropertyColor.dataSource.count != 0 && dataPropertyTalla.dataSource.count != 0)
            {
              
            }
            else if(dataPropertyColor.dataSource.count != 0 && dataPropertyTalla.dataSource.count == 0)
            {
            
            }
            else if(dataPropertyColor.dataSource.count == 0 && dataPropertyTalla.dataSource.count != 0)
            {
                
            }
        }
        else if(dataSource.count == 1)
        {
            
        }
    }*/
}
