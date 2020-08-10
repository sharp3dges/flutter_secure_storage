#import "FlutterSecureStoragePlugin.h"
#import "KeychainWrapper.h"

static NSString *const CHANNEL_NAME = @"plugins.it_nomads.com/flutter_secure_storage";

static NSString *const InvalidParameters = @"Invalid parameter's type";

@interface FlutterSecureStoragePlugin()

@property (strong, nonatomic) KeychainWrapper *wrapper;

@end

@implementation FlutterSecureStoragePlugin

- (instancetype)init {
    self = [super init];
    if (self){
        self.wrapper = [[KeychainWrapper alloc] init];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    FlutterSecureStoragePlugin* instance = [[FlutterSecureStoragePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = [call arguments];
    NSDictionary *options = [arguments[@"options"] isKindOfClass:[NSDictionary class]] ? arguments[@"options"] : nil;

    if ([@"read" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        NSString *groupId = options[@"groupId"];
        NSString *value = [self read:key forGroup:groupId];
        
        result(value);
    } else
    if ([@"write" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        NSString *value = arguments[@"value"];
        NSString *groupId = options[@"groupId"];
        NSString *accessibility = options[@"accessibility"];        
        if (![value isKindOfClass:[NSString class]]){
            result(InvalidParameters);
            return;
        }
        
        [self write:value forKey:key forGroup:groupId accessibilityAttr:accessibility];
        
        result(nil);
    } else if ([@"delete" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        NSString *groupId = options[@"groupId"];
        [self delete:key forGroup:groupId];
        
        result(nil);
    } else if ([@"deleteAll" isEqualToString:call.method]) {
        NSString *groupId = options[@"groupId"];
        [self deleteAll: groupId];
        
        result(nil);
    } else if ([@"readAll" isEqualToString:call.method]) {
        NSString *groupId = options[@"groupId"];
        NSDictionary *value = [self readAll: groupId];

        result(value);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)write:(NSString *)value forKey:(NSString *)key forGroup:(NSString *)groupId accessibilityAttr:(NSString *)accessibility {
    [wrapper mySetObject:(id)value forKey:(id)key];
}

- (NSString *)read:(NSString *)key forGroup:(NSString *)groupId {
    return [wrapper myObjectForKey:(id)key];
}

- (void)delete:(NSString *)key forGroup:(NSString *)groupId {
    [wrapper deleteKey:(id)key];
}

- (void)deleteAll:(NSString *)groupId {
    [wrapper deleteAll];
}

- (NSDictionary *)readAll:(NSString *)groupId {
    NSMutableDictionary *search = [self.query mutableCopy];
    if(groupId != nil) {
        search[(__bridge id)kSecAttrAccessGroup] = groupId;
    }
    
    search[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

    search[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    search[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;

    CFArrayRef resultData = NULL;
    
    OSStatus status;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)search, (CFTypeRef*)&resultData);
    if (status == noErr){
        NSArray *items = (__bridge NSArray*)resultData;
        
        NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
        for (NSDictionary *item in items){
            NSString *key = item[(__bridge NSString *)kSecAttrAccount];
            NSString *value = [[NSString alloc] initWithData:item[(__bridge NSString *)kSecValueData] encoding:NSUTF8StringEncoding];
            results[key] = value;
        }
        return [results copy];
    }
    
    return @{};
}

@end
