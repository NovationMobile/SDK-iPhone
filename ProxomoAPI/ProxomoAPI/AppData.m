//
//  AppData.m
//  PROXOMO
//
//  Created by Charisse Dirain on 10/26/11.
//  Copyright (c) 2011 Proxomo. All rights reserved.
//

#import "ProxomoApi+Proxomo.h"
#import "ProxomoObject+Proxomo.h"
#import "ProxomoList+Proxomo.h"
#import "AppData.h"

#define DEFAULT_OBJECTYPE @"PROXOMO"

@implementation AppData

@synthesize Key, Value, ObjectType;

-(void) initValue:(NSString*)value foKey:(NSString*)key objectType:(NSString*)objectType proxomoId:(NSString*)proxomoId{
    ID = proxomoId;
    Key = key;
    Value = value;
    ObjectType = objectType;
}

-(id)initWithValue:(NSString*)value forKey:(NSString*)key {
    self = [super init];
    if(self){
        [self initValue:value foKey:key objectType:DEFAULT_OBJECTYPE proxomoId:nil];
    }
    return self;
}

-(id)initWithValue:(NSString*)value forKey:(NSString*)key objectType:(NSString*)objectType {
    self = [super init];
    if(self){
        [self initValue:value foKey:key objectType:objectType proxomoId:nil];
    }
    return self;
}

-(id)initWithValue:(NSString*)value forKey:(NSString*)key objectType:(NSString*)objectType proxomoId:(NSString*)proxomoId
{
    self = [super init];
    if(self){
        [self initValue:value foKey:key objectType:objectType proxomoId:proxomoId];
    }
    return self;
}

#pragma mark - JSON Data Support

-(void) updateFromJsonRepresentation:(NSDictionary*)jsonRepresentation{
    if(jsonRepresentation){
        Key = [jsonRepresentation objectForKey:@"Key"];
        Value = [jsonRepresentation objectForKey:@"Value"];
        ObjectType = [jsonRepresentation objectForKey:@"ObjectType"];
        [super updateFromJsonRepresentation:jsonRepresentation];
    }
}

-(NSMutableDictionary*)jsonRepresentation{
    NSMutableDictionary *dict = nil;
    
    dict = [super jsonRepresentation];
    if (Key) [dict setValue:Key forKey:@"Key"];
    if (Value) [dict setValue:Value forKey:@"Value"];
    if (ObjectType) [dict setValue:ObjectType forKey:@"ObjectType"];
    
    return dict;
}

#pragma mark - API Delegate
-(enumObjectType) objectType{
    return APPDATA_TYPE;
}

-(void) handleError:(NSData*)response requestType:(enumRequestType)requestType responseCode:(NSInteger)code responseStatus:(NSString*) status{
    [super handleError:response requestType:requestType responseCode:code responseStatus:status];
}

-(void) handleResponse:(NSData *)response requestType:(enumRequestType)requestType  responseCode:(NSInteger)code responseStatus:(NSString *)status{
    [super handleResponse:response requestType:requestType  responseCode:code responseStatus:status];
}


+(void)getAllInContext:(ProxomoApi*)context intoList:(ProxomoList*)proxomoList useAsync:(BOOL)useAsync{
    if(useAsync){
        [context GetAll:proxomoList getType:APPDATA_TYPE];
    }else{
        [context GetAll_Synchronous:proxomoList getType:APPDATA_TYPE];
    }
}

+(void)searchInContext:(ProxomoApi*)context forObjectType:(NSString*)objectType intoList:(ProxomoList*)proxomoList useAsync:(BOOL)useAsync{
    [context Search:proxomoList searchUrl:@"/search/objecttype" searchUri:objectType forListType:APPDATA_TYPE useAsync:useAsync];
}


@end