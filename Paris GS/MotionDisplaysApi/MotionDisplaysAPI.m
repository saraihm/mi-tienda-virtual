//
//  MotionDisplaysApi.m
//  PPrueba
//
//  Created by Sarai Henriquez on 14-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

#import "Reachability.h"
#import "MotionDisplaysApi.h"
#import "Paris_GS-Swift.h"


@implementation MotionDisplaysApi

@synthesize country, baseurl;

- (id)init
{
    self = [super initWithBaseURL:nil];
    if (!self) {
        return nil;
    }
    _operationIsCanceling = NO;
    [self refreshCurrentCountry];
    [self refreshBaseURLs];
    
    _currentActiveOperations = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    
    //setuprequest
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/form-data; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    _isConnectionAvailable = NO;
    [self.reachabilityManager startMonitoring];
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"STATUS CODE: %li", (long)status);
        if (status == AFNetworkReachabilityStatusNotReachable) {
            // Not reachable
            NSLog(@"NOT REACHABLE");
            _isConnectionAvailable = NO;
        } else {
            // Reachable
            NSLog(@"REACHABLE");
            _isConnectionAvailable = YES;
        }
    }];
    return self;
}

+ (void) refreshBaseURLs {
    __weak MotionDisplaysApi *mdApi = [MotionDisplaysApi sharedClient];
    [mdApi refreshBaseURLs];
}
#pragma mark - MD Api singleton

+ (MotionDisplaysApi *)sharedClient {
    static MotionDisplaysApi * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];

    });
    NSLog(@"sharedClient: %@",_sharedClient);
    return _sharedClient;
}

#pragma mark - AFNetworking Based Methods (REST)

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                    parameters:(id) parsedParameters
                            errorMessageActive:(BOOL) errorActive
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error)) failure {
    
   
    [MotionDisplaysApi JSONRequestOperationPOSTWithStringURL:endPoint
                                                     baseURL:[[self class] sharedClient].baseurl
                                                  parameters:parsedParameters
                                          errorMessageActive:errorActive
                                                     success:success
                                                     failure:failure];
    
}

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                    parameters:(id) parsedParameters
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error)) failure {
    
    
    [MotionDisplaysApi JSONRequestOperationPOSTWithStringURL:endPoint
                                                  parameters:parsedParameters
                                          errorMessageActive:YES
                                                     success:success
                                                     failure:failure];
    
}

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                       baseURL:(NSString*) baseURL
                                    parameters:(id) parsedParameters
                            errorMessageActive:(BOOL) errorActive
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error)) failure {
  
    MotionDisplaysApi *mdapi = [[self class] sharedClient];
    if(mdapi == nil)
    {
        static MotionDisplaysApi * _sharedClient = nil;
        _sharedClient = [[self alloc] init];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        mdapi = _sharedClient;
         NSLog(@"sharedClient: NULL");
    }
    
    mdapi.isErrorMessagesActive = errorActive;
    NSLog(@"errorActive: %i", errorActive);
    NSString *finalURL = [baseURL stringByAppendingString:endPoint];
    NSLog(@"finalURL: %@",finalURL);

    //    if(mdapi.isConnectionAvailable) {
    __weak NSURLSessionTask *operation = [mdapi
                    POST:finalURL
                    parameters:parsedParameters
                    constructingBodyWithBlock: nil
                    progress:nil
                    success:^(NSURLSessionTask *operation, id JSON){
                                NSLog(@"RESULT SUCCESS");
                                success(operation,JSON,[MotionDisplaysApi handleErrorCode:JSON mdApi:(MotionDisplaysApi*) mdapi]);
                    }
                    failure:^(NSURLSessionTask *operation, NSError *error) {
                         NSLog(@"Error:!!!");
                        if(operation != nil && error != nil)
                        {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) operation.response;
                            NSLog(@"Error: %@",error);
                            NSLog(@"response.statusCode: %ld",(long)httpResponse.statusCode);
                            NSLog(@"Error User Info: %@",error.userInfo);
                            NSLog(@"Error Code: %li",(long)error.code);
                            if(error.code!=-999&&errorActive) {
                                NSString *alertMsg;
                                NSString *alertTitle;
                                if(httpResponse.statusCode==0){
                                    alertTitle = @"Error de Conexión";
                                } else {
                                    alertTitle = [NSString stringWithFormat:@"Error: %li",(long)httpResponse.statusCode];
                                }
                                
                                alertMsg = error.localizedDescription;
                                if(mdapi.isConnectionAvailable) {
                                    
                                    UIAlertController * alertController = [UIAlertController
                                                                           alertControllerWithTitle:alertTitle
                                                                           message:alertMsg
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* ok = [UIAlertAction
                                                         actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                                         {
                                                             [alertController dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                         }];
                                    
                                    [alertController addAction:ok];
                                    
                                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:true completion:nil];
                                    
                                }
                            }
                        }
                        
                        failure(nil,error);
                    }];
    [mdapi.currentActiveOperations setObject:operation forKey:[NSNumber numberWithInteger:mdapi.operationIndex]];
    mdapi.operationIndex++;
}

+ (void) JSONRequestOperationGETWithStringURL:(NSString*) endPoint
                                   parameters:(id) parsedParameters
                                      success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                      failure:(void(^)(NSURLSessionTask *operation, NSError *error))
                                      failure {
    
    MotionDisplaysApi *mdapi = [[self class] sharedClient];
    NSString *finalURL = [mdapi.baseurl stringByAppendingString:endPoint];
    NSLog(@"finalURL: %@",finalURL);
    //    if(mdapi.isConnectionAvailable) {
    [mdapi
     GET:finalURL
     parameters:parsedParameters
     progress:nil
     success:^(NSURLSessionTask *operation, id JSON){
         
         
         NSLog(@"JSON: %@",JSON);
         success(operation,JSON,[MotionDisplaysApi handleErrorCode:JSON mdApi:mdapi]);
     } failure:^(NSURLSessionTask *operation, NSError *error) {
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) operation.response;
         NSLog(@"Error: %@",error);
         NSLog(@"response.statusCode: %ld",(long)httpResponse.statusCode);
         NSLog(@"Error User Info: %@",error.userInfo);
         NSString *alertMsg;
         
         if(httpResponse.statusCode==500){
             NSString *temp = [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
             alertMsg = [NSString stringWithFormat:kMDErrorUnknowError, temp];
         } else {
             alertMsg = [NSString stringWithFormat:@"Falla en la conexión (codigo %ld). Favor intente nuevamente o consultar al administrador de Red", (long)httpResponse.statusCode];
         }
         
         UIAlertController * alertController = [UIAlertController
                                                alertControllerWithTitle:@"Error"
                                                message:alertMsg
                                                preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* ok = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alertController dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
         
         [alertController addAction:ok];
         
         [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:true completion:nil];
         
         failure(operation,error);
         
     }];

}

+ (void) JSONRequestOperationGETWithUrl:(NSString*) fullUrl
                                success:(void(^)(id JSON)) success
                                failure:(void(^)(NSError *error))
                                failure {
    
    [[self class] JSONRequestOperationGETWithUrl:fullUrl
                                         timeout:60
                                         success:success
                                         failure:failure];
}

+ (void) JSONRequestOperationGETWithUrl:(NSString*) fullUrl
                                timeout:(NSTimeInterval) timeInterval
                                success:(void(^)(id JSON)) success
                                failure:(void(^)(NSError *error))
                                failure {
    
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeInterval];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {

        if (data&&!error) {

                if(success)success(data);

        } else {
            NSLog(@"JSONRequestOperationGET Error loading data: %@", error);
            if(failure)failure(error);
        }

    }];
    
    [task resume];

}




+ (BOOL) handleErrorCode:(id) JSON mdApi:(MotionDisplaysApi*) mdapi {
    __block BOOL hasError = YES;
    __block NSString *alertMsg = @"";
    __block NSString *errorCodeString = @"Unknown";
     __block NSString *logoutString = @"Unknown";
    if(JSON) {
        id errorCode = [JSON valueForKey:@"data"];
        id logout = [JSON objectForKey:@"logout"];
        
        if(errorCode&&[errorCode isKindOfClass:[NSNumber class]]) {
            errorCodeString = [NSString stringWithFormat:@"%@",errorCode];
            logoutString = [NSString stringWithFormat:@"%@",logout];
            NSLog(@"has error: %@", errorCodeString);
            if([errorCodeString isEqual: @"0"] && logout != nil) {
                if([logoutString isEqual: @"1"])
                {
                    alertMsg = kMDErrorInvalidSessionToken;
                    mdapi.isErrorMessagesActive = YES;
                    AppDelegate *appDelegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate forceLogin];
                }
                else
                {
                    alertMsg = [JSON valueForKey:@"message"];
                    mdapi.isErrorMessagesActive = YES;
                }
            }
            else if([errorCodeString isEqual: @"0"]) {
                alertMsg = [JSON valueForKey:@"message"];
                mdapi.isErrorMessagesActive = YES;
            }
            else if([errorCodeString isEqual: @"1"]) {
                hasError = NO;
                NSLog(@"hans't error");
            }
            
            if(!alertMsg)
            {
                alertMsg = kMDErrorNullResponse;
            }
            
            
        } else {
            hasError = NO;
            NSLog(@"hans't error");
        }
    }
    
    if (hasError&&mdapi.isErrorMessagesActive) {
        
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle:[NSString stringWithFormat:@"Error: %@", errorCodeString]
                                               message:alertMsg
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alertController addAction:ok];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:true completion:nil];
    }
    return hasError;
}

- (void) refreshCurrentCountry {
    id bruteCountry = [[NSUserDefaults standardUserDefaults] objectForKey:kMainCountry];
    if (bruteCountry) country = [bruteCountry integerValue];
    else country = MDCountryCL;
    NSLog(@"refreshCurrentCountry\ncurrent country: %li",(long)country);
    [self refreshBaseURLs];
}

- (void) refreshBaseURLs {

    baseurl = [[NSUserDefaults standardUserDefaults] valueForKey:kMainDomain];
    
    NSLog(@"refreshBaseURLs\nBASE URL REST: %@", baseurl);

}


+ (BOOL)internetConnection {
    
    BOOL status = YES;
    
    //1st. FIRST check INTERNET reachability
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        
        //only show error alert if not already shown
        
        UIAlertController * alertController = [UIAlertController
                                               alertControllerWithTitle:@"Conexion Internet"
                                               message:@"No se puede establecer conexión, verifique su configuración o solicite soporte al administrador de red."
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alertController addAction:ok];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:true completion:nil];
        
        status = NO;
        
    } else {
        NSLog(@"There IS internet connection");
        status = YES;
    }
    
    return status;
}

+ (void) cancelAllCurrentActiveOperations {
    __weak MotionDisplaysApi *mdApi = [MotionDisplaysApi sharedClient];
    [mdApi cancelAllCurrentActiveOperations];
}

- (void) cancelAllCurrentActiveOperations {
    _operationIsCanceling = YES;
    NSArray *keys = [[_currentActiveOperations keyEnumerator] allObjects];
    NSLog(@"keys: %@",keys);
    //    for (NSString *key in keys) {
    for (NSInteger i=0;i<keys.count;i++) {
        NSString *key = keys[i];
        NSURLSessionTask *operation = [_currentActiveOperations objectForKey:key];
        if(operation) {
            [operation cancel];
            NSLog(@"operation cancelled: %@",operation);
        } else NSLog(@"invalid operation");
        if(keys.count==i+1) _operationIsCanceling = NO;
    }
    //    [_currentActiveOperations removeAllObjects];
    _operationIndex = 0;
}

@end
