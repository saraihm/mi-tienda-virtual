//
//  MDCountryInfixManager.h
//  Falabella
//
//  Created by Erick Reategui on 09-07-15.
//  Copyright (c) 2015 MotionDisplays. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MDCountry) {
    MDCountryCL,
    MDCountryPE,
    MDCountryAR,
    MDCountryCO
};

@interface MDCountryInfixManager : NSObject

+ (MDCountry)countryWithStringInfix:(NSString*) stringInfix;
+ (NSString*)stringInfixWithCountry:(MDCountry) country;
+ (NSString*)stringF12InfixWithCountry:(MDCountry) country;

@end
