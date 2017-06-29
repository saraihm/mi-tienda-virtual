//
//  MDSimulateEnviroment.swift
//  Paris GS
//
//  Created by Sarai Henriquez on 07-09-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSimulateEnviroment: NSObject {

    var floorOptions = Array<MDSimulateOption>()
    var wallOptions = Array<MDSimulateOption>()
    
    
    func getSimulateEnviromentOptions(classID: Int, hasError: @escaping (Bool) -> ()){

        let parameters = ["category": ["id": classID]]
        print("parameters: ", parameters)

            let path = kWSSimulate
            print("path: ", path)
            
            if(MotionDisplaysApi.internetConnection())
            {
                MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                    
                    if(!hasResponseError && jsonResponse != nil)
                    {
                        let json = JSON(jsonResponse as AnyObject)
                        let data = json["data"].dictionary
                        if(data == nil)
                        {
                            print("ERROR ON DATA")
                            hasError(true)
                        }
                        else
                        {
                            let structures = data?["structures"]?.array
                            for options: JSON in structures!
                            {
                                if(options["name"].string == "Piso")
                                {
                                    for option: Any in options["multimedia"].arrayObject!
                                    {
                                        let option = MDSimulateOption.init(attributes: option as! Dictionary<String, AnyObject>)
                                        if(option != nil)
                                        {
                                            self.floorOptions.append(option!)
                                        }
                                    }
                                }
                                
                                if(options["name"].string == "Pared")
                                {
                                    for option: Any in options["multimedia"].arrayObject!
                                    {
                                        let option = MDSimulateOption.init(attributes: option as! Dictionary<String, AnyObject>)
                                        if(option != nil)
                                        {
                                            self.wallOptions.append(option!)
                                        }
                                    }
                                }
                               
                            }
                            
                            hasError(false)
                        }
                    }
                    else
                    {
                        hasError(true)
                    }
                    
                    },failure: { (error: Error) in
                        hasError(true)
                })

            }
            else
            {
                hasError(true)
            }       
    }

}
