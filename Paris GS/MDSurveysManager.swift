//
//  MDSurveysManager.swift
//  Paris GS
//
//  Created by Motion Displays on 12-12-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

import UIKit

class MDSurveysManager: NSObject {
    
    var options = Array<MDOptionSurvey>()
    var title: String!
    var id: Int!
    
    func getSurveysSummary(hasError: @escaping (Bool) -> ()){
        
        let path = kWSurverySummary
        print("path: ", path)
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationGET(withEndPoint: path, parameters: nil, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
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
                        for option: Any in data!["options"]!.arrayObject!
                        {
                            let option = MDOptionSurvey.init(attributes: option as! Dictionary<String, AnyObject>)
                            if(option != nil)
                            {
                                self.options.append(option!)
                            }
                        }
                        
                        self.title = data!["title"]!.stringValue
                        self.id = data!["id"]!.intValue
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
    
    func setSurveysReviewPositive(surveyId: Int, optionId: Int, hasError: @escaping (Bool) -> ()){
     
        let parameters = ["review": ["survey":surveyId, "option": optionId]] as [String : Any]
        print("parameters: ", parameters)
        
        let path = kWSurveryReview
        print("path: ", path)
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].bool
                   
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        hasError(!data!)
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
    
    func setSurveysReviewNegative(surveyId: Int, optionId: Int, reasonId: Int, hasError: @escaping (Bool) -> ()){
        
        let parameters = ["review": ["survey":surveyId, "option": optionId, "reason": reasonId]] as [String : Any]
        print("parameters: ", parameters)
        
        let path = kWSurveryReview
        print("path: ", path)
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].bool
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        hasError(!data!)
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
    
    func setSurveysReviewNegative(withCommnet: String, surveyId: Int, optionId: Int, hasError: @escaping (Bool) -> ()){
        
        let parameters = ["review": ["survey":surveyId, "option": optionId, "comment": withCommnet]] as [String : Any]
        print("parameters: ", parameters)
        
        let path = kWSurveryReview
        print("path: ", path)
        
        if(MotionDisplaysApi.internetConnection())
        {
            MotionDisplaysApi.jsonRequestOperationPOST(withEndPoint: path, parameters: parameters, success: { ( jsonResponse: Any?, hasResponseError: Bool) in
                if(!hasResponseError && jsonResponse != nil)
                {
                    let json = JSON(jsonResponse as AnyObject)
                    let data = json["data"].bool
                    
                    if(data == nil)
                    {
                        print("ERROR ON DATA")
                        hasError(true)
                    }
                    else
                    {
                        hasError(!data!)
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
