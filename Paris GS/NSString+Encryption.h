//
//  NSString+Encryption.h
//  Falabella
//
//  Created by Erick Reategui on 22-07-15.
//  Copyright (c) 2015 MotionDisplays. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSData+AESCrypt.h"

@interface NSString (Encryption)

- (NSString*)SHA1Encrypt;
- (NSString*)AES128EncryptWithKey:(NSString *)key;
- (NSString*)AES128DecryptWithKey:(NSString *)key;
+ (NSString*)mdEncryptionAlgorithmWithValue:(NSString*) valueToConvert referencePIN:(NSString*) pin;
+ (NSString*)mdDecryptionAlgorithmWithValue:(NSString*) valueToConvert referencePIN:(NSString*) pin;

@end
