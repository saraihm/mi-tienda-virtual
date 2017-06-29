//
//  MotionDisplaysApi.h
//  PPrueba
//
//  Created by Sarai Henriquez on 14-07-16.
//  Copyright © 2016 Motion Displays. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"
#import "MDCountryInfixManager.h"
@class MDTools;

@interface MotionDisplaysApi : AFHTTPSessionManager

@property (nonatomic, assign) BOOL operationIsCanceling;
@property (nonatomic, strong, readonly) NSMapTable *currentActiveOperations;
@property (nonatomic, assign) __block BOOL isConnectionAvailable, isErrorMessagesActive;
@property (nonatomic, strong) NSString* baseurl;/Volumes/NO NAME/Proyectos iOS/Paris GS Swift 3 /Paris GS/MotionDisplaysApi/MotionDisplaysAPI.m
@property (nonatomic, assign) NSInteger operationIndex;
@property (nonatomic, assign) MDCountry country;


- (id)init;
+ (MotionDisplaysApi *)sharedClient;

+ (BOOL)internetConnection;

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                    parameters:(id) parsedParameters
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error))
failure;

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                    parameters:(id) parsedParameters
                            errorMessageActive:(BOOL) errorActive
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error)) failure;

+ (void) JSONRequestOperationGETWithStringURL:(NSString*) endPoint
                                   parameters:(id) parsedParameters
                                      success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                      failure:(void(^)(NSURLSessionTask *operation, NSError *error))
failure;

+ (void) JSONRequestOperationPOSTWithStringURL:(NSString*) endPoint
                                       baseURL:(NSString*) baseURL
                                    parameters:(id) parsedParameters
                            errorMessageActive:(BOOL) errorActive
                                       success:(void(^)(NSURLSessionTask *operation, id JSON, BOOL hasResponseError)) success
                                       failure:(void(^)(NSURLSessionTask *operation, NSError *error)) failure;


+ (void) JSONRequestOperationGETWithUrl:(NSString*) fullUrl
                                success:(void(^)(id JSON)) success
                                failure:(void(^)(NSError *error)) failure;

+ (void) JSONRequestOperationGETWithUrl:(NSString*) fullUrl
                                timeout:(NSTimeInterval) timeInterval
                                success:(void(^)(id JSON)) success
                                failure:(void(^)(NSError *error)) failure;


+ (void) cancelAllCurrentActiveOperations;
+ (void) refreshBaseURLs;


@end
