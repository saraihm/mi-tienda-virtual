//
//  MDVariatnDataSource.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 30-08-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class MDVariatnDataSource: NSObject {

    var type: String!
    var dataSource = NSMutableArray()
    var generatedVariants = Array<MDVariant>()
    var variants = Array<MDVariant>()
    var selectedIndex = -1
    var selectedValue = "-1"
    var selectedName: String?

    init(type: String) {
        self.type = type
    }
    
    func setDataSource(_ variants: Array<MDVariant>, setSelection: Bool, withSimulation: Bool)  {
        var setSelection = setSelection
        generatedVariants = variants
        self.variants = variants
       // let propertiesTemp = NSMutableDictionary()
        var propertiesTemp = Array<MDVariantProperty>()
        for variant in variants {
            if(withSimulation)
            {
                if(variant.preview)
                {
                    for property in variant.properties {
                        if(property.key == type)
                        {
                            propertiesTemp.append(property)
                        }
                        
                        if(selectedValue == property.value && selectedName == property.name)
                        {
                            setSelection = false
                        }
                    }
                }
            }
            else
            {
                for property in variant.properties {
                    if(property.key == type)
                    {
                        propertiesTemp.append(property)
                    }
                    if(selectedValue == property.value && selectedName == property.name)
                    {
                        setSelection = false
                    }
                }

            }
        }
        
        dataSource.removeAllObjects()
        dataSource = NSMutableArray(array: propertiesTemp)
        sortDataSource()
        
        if(setSelection == true)
        {
            self.setSelectionDefault()
        }
    }
    
    func sortDataSource()  {
        if(type == "Talla")
        {
            let propertiesTemp = NSMutableArray(array: dataSource)
            dataSource.removeAllObjects()
            while propertiesTemp.count > 1 {
                var propertySmall = propertiesTemp[0]
                for index in 0...propertiesTemp.count {
                    let property = propertiesTemp[index] as! MDVariantProperty
                    if(Float(property.value) < Float((propertySmall as AnyObject).value))
                    {
                        propertySmall = property
                    }
                }
                dataSource.add(propertySmall)
                propertiesTemp.remove(propertySmall)
            }
            
            if(propertiesTemp.count>0)
            {
                dataSource.add(propertiesTemp[0])
                propertiesTemp.removeAllObjects()

            }
            
        }
    }
    
    func setSelectionDefault()  {
        if(dataSource.count > 0)
        {
            selectedIndex = 0
            selectedValue = (dataSource[0] as! MDVariantProperty).value
            selectedName = (dataSource[0] as! MDVariantProperty).name
        }
    }
    
    func setSelectionWithValue(_ value: String, name: String?)  {
        selectedValue = value
        selectedName = name
        updateSelectedIndex(true)
    }
    
    func updateSelectedIndex(_ updateVariants: Bool)  {
        if(selectedValue != "-1")
        {
            for property in dataSource {
                if((property as! MDVariantProperty).value == selectedValue && (property as! MDVariantProperty).name == selectedName)
                {
                    selectedIndex = dataSource.index(of: property)
                }
            }
        }
        else
        {
            self.setSelectionDefault()
            self.updateGeneratedVariant()
        }
    }
    
    func updateGeneratedVariant()  {
        generatedVariants.removeAll()
        for variant in variants {
            for property in variant.properties {
                if(property.value == selectedValue && property.name == selectedName)
                {
                    generatedVariants.append(variant)
                    break
                }
            }
        }
    }
    
    func currentVariant() -> MDVariant?{
        for variant in variants {
            for property in variant.properties {
                if(selectedValue == property.value && selectedName == property.name)
                {
                    return variant
                }
            }
        }
        
        return nil
    }
}
