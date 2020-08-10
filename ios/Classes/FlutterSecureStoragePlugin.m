#import "FlutterSecureStoragePlugin.h"
#import "KeychainWrapper.h"

static NSString *const CHANNEL_NAME = @"plugins.sharp3dges.com/flutter_secure_storage";

static NSString *const InvalidParameters = @"Invalid parameter's type";

@interface FlutterSecureStoragePlugin()

@property (strong, nonatomic) KeychainWrapper *wrapper;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

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
    } else if ([@"write" isEqualToString:call.method]) {
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
    } else if ([@"readAllShared" isEqualToString:call.method]) {
        result([_userDefaults dictionaryRepresentation]);
    } else if ([@"readShared" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        result([_userDefaults objectForKey:key]);
    } else if ([@"writeShared" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        NSString *value = arguments[@"value"];
        [_userDefaults setObject:value forKey:key];
        result(nil);
    } else if ([@"deleteShared" isEqualToString:call.method]) {
        NSString *key = arguments[@"key"];
        NSString *value = arguments[@"value"];
        [_userDefaults removeObjectForKey:key];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)write:(NSString *)value forKey:(NSString *)key forGroup:(NSString *)groupId accessibilityAttr:(NSString *)accessibility {
    [_wrapper mySetObject:(id)value forKey:(id)key];
}

- (NSString *)read:(NSString *)key forGroup:(NSString *)groupId {
    return [_wrapper myObjectForKey:(id)key];
}

- (void)delete:(NSString *)key forGroup:(NSString *)groupId {
    [_wrapper deleteKey:(id)key];
}

- (void)deleteAll:(NSString *)groupId {
    [_wrapper deleteAll];
}

- (NSDictionary *)readAll:(NSString *)groupId {
    return [_wrapper getAll];
}

@end
