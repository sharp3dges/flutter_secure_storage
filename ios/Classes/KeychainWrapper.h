//
//  KeychainWrapper.h
//  
//
//  Created by Sjoerd Berg on 10/08/2020.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface KeychainWrapper : NSObject

- (void)mySetObject:(id)inObject forKey:(id)key;
- (id)myObjectForKey:(id)key;
- (void)deleteAll;
- (void)deleteKey:(id)key;
- (void)writeToKeychain;

@end
