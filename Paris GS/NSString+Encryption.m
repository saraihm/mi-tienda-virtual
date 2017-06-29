//
//  NSString+Encryption.m
//  Falabella
//
//  Created by Erick Reategui on 22-07-15.
//  Copyright (c) 2015 MotionDisplays. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "NSString+Encryption.h"

//#define kEncryptKeyPrefix          @"lasBaratas"
//#define kEncryptKeyInfix           @"delTLB"

@implementation NSString (Encryption)

- (NSString*)SHA1Encrypt
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString*)AES128EncryptWithKey:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES128EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64EncodedStringWithOptions:kNilOptions];
    
    return encryptedString;
}

- (NSString*)AES128DecryptWithKey:(NSString *)key
{
    NSData *plainData = [[NSData alloc] initWithBase64EncodedString:self options:kNilOptions];
    NSData *encryptedData = [plainData AES128DecryptWithKey:key];
    NSString *decryptedString = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
    return decryptedString;
}

+ (NSString*)mdEncryptionAlgorithmWithValue:(NSString*) valueToConvert referencePIN:(NSString*) pin {
    NSLog(@"\n mdEncryptionAlgorithmWithValue: %@ \n referencePIN: %@",valueToConvert, pin);
    
    NSString *originalValue = [NSString stringWithString:valueToConvert];
    NSInteger shaCounter = 2;
    for (NSInteger tlbCounter=pin.length; tlbCounter>0; tlbCounter--) {
        for (NSInteger i=0; i<shaCounter; i++) {
            pin = pin.SHA1Encrypt;
        }
        if(shaCounter==65)shaCounter=2;
        else shaCounter = shaCounter*2-1;
        NSString * key = [pin substringWithRange:NSMakeRange(0, 16)];
        NSLog(@"========================");
        NSLog(@"%i - key: %@",tlbCounter,key);
        valueToConvert = [valueToConvert AES128EncryptWithKey:key];
        NSLog(@"%i - value with AES128: %@",tlbCounter,valueToConvert);
        NSLog(@"%i - pin encrypted: %@",tlbCounter,pin);
        NSLog(@"%i - index: %i",tlbCounter,shaCounter);
        
    }
    NSLog(@"originalValue: %@ result: %@ resultLength: %i",originalValue,valueToConvert,valueToConvert.length);
    return valueToConvert;
}

+ (NSString*)mdDecryptionAlgorithmWithValue:(NSString*) valueToConvert referencePIN:(NSString*) pin {
    NSLog(@"\n mdDecryptionAlgorithmWithValue: %@ \n referencePIN: %@",valueToConvert, pin);
    
    NSString *originalValue = [NSString stringWithString:valueToConvert];
    NSInteger shaCounter = 2;
    NSMutableArray *keys = [NSMutableArray array];
    for (NSInteger tlbCounter=pin.length; tlbCounter>0; tlbCounter--) {
        for (NSInteger i=0; i<shaCounter; i++) {
            pin = pin.SHA1Encrypt;
        }
        if(shaCounter==65)shaCounter=2;
        else shaCounter = shaCounter*2-1;
        NSString * key = [pin substringWithRange:NSMakeRange(0, 16)];
        NSLog(@"========================");
        NSLog(@"%i - key: %@",tlbCounter,key);
        [keys addObject:key];
        NSLog(@"%i - pin encrypted: %@",tlbCounter,pin);
        NSLog(@"%i - index: %i",tlbCounter,shaCounter);
        
    }
    for(int i=keys.count;i>0;i--) {
        NSLog(@"==========");
        NSLog(@"%i - value before: %@",i-1,valueToConvert);
        valueToConvert = [valueToConvert AES128DecryptWithKey:keys[i-1]];
        NSLog(@"%i - value after: %@",i-1,valueToConvert);
    }
    
    NSLog(@"originalValue: %@ valueToConvert: %@ resultLength: %i",originalValue,valueToConvert,valueToConvert.length);
    return valueToConvert;
}

@end
