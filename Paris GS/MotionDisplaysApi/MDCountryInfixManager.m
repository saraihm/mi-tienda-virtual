//
//  MDCountryInfixManager.m
//  Falabella
//
//  Created by Erick Reategui on 09-07-15.
//  Copyright (c) 2015 MotionDisplays. All rights reserved.
//

#import "MDCountryInfixManager.h"


@implementation MDCountryInfixManager

+ (MDCountry)countryWithStringInfix:(NSString*) stringInfix{
    if([stringInfix isEqualToString:kTestInfixCL]||[stringInfix isEqualToString:kProdInfixCL])
        return MDCountryCL;
    else if([stringInfix isEqualToString:kTestInfixPE]||[stringInfix isEqualToString:kProdInfixPE])
        return MDCountryPE;
    else if([stringInfix isEqualToString:kTestInfixAR]||[stringInfix isEqualToString:kProdInfixAR])
        return MDCountryAR;
    else if([stringInfix isEqualToString:kTestInfixCO]||[stringInfix isEqualToString:kProdInfixCO])
        return MDCountryCO;
    return MDCountryCL;
}

+ (NSString*)stringInfixWithCountry:(MDCountry) country {
    if([[self class] isInProd]) {
        switch (country) {
            case MDCountryCL:
                return kProdInfixCL;
                break;
            case MDCountryPE:
                return kProdInfixPE;
                break;
            case MDCountryAR:
                return kProdInfixAR;
                break;
            case MDCountryCO:
                return kProdInfixCO;
                break;
        }
    } else {
        switch (country) {
            case MDCountryCL:
                return kTestInfixCL;
                break;
            case MDCountryPE:
                return kTestInfixPE;
                break;
            case MDCountryAR:
                return kTestInfixAR;
                break;
            case MDCountryCO:
                return kTestInfixCO;
                break;
        }
    }
}

+ (NSString*)stringF12InfixWithCountry:(MDCountry) country {
    switch (country) {
        case MDCountryCL:
            return kF12InfixCL;
            break;
        case MDCountryPE:
            return kF12InfixPE;
            break;
        case MDCountryAR:
            return kF12InfixAR;
            break;
        case MDCountryCO:
            return kF12InfixCO;
            break;
    }
}


+(BOOL) isInProd {
    NSString *domain = [[NSUserDefaults standardUserDefaults] valueForKey:kMainDomain];
    if(domain) {
        return [domain isEqualToString:kUrlFalabellaProduction];
    } else return YES;
}

@end
