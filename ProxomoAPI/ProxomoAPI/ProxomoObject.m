//
//  ProxomoObject.m
//  ProxomoAPI
//
//  Created by Fred Crable on 11/27/11.
//  Copyright (c) 2011 Proxomo. All rights reserved.
//

#import "ProxomoObject.h"
#import "ProxomoList.h"
#import "CustomData.h"
#import "SBJson.h"
#import <objc/runtime.h>

@implementation ProxomoObject

@synthesize restResponse;
@synthesize ID;
@synthesize appDelegate;
@synthesize _apiContext;
@synthesize _accessToken;

-(id) init {
    self = [super init];
    if(self){
        appDelegate = nil;
    }
    return self;
}

-(id)initWithID:(NSString*)objectdId{
    self = [super init];
    if(self){
        [self setID:objectdId];
        appDelegate = nil;
    }
    return self;
}

-(enumObjectType) objectType{
    return GENERIC_TYPE;
}

-(NSString *) objectPath:(enumRequestType)requestType{
    return @"";
}

-(void)setApiContext:(id)apiContext{
    _apiContext = apiContext;
}

// adds the object, sets the ID in object
-(void) Add:(id)context  
{   
    if([context isKindOfClass:[ProxomoApi class]]){
        _apiContext = context;
        [_apiContext Add:self inObject:nil];
    }else{
        _apiContext = [context _apiContext];
        [_apiContext Add:self inObject:context];
    }
}

// updates or creates a single instance from object
// asynchronously updates or creates a single instance
// ID must be set in object
-(void) Update:(id)context 
{
    if([context isKindOfClass:[ProxomoApi class]]){
        _apiContext = context;
        [_apiContext Update:self inObject:nil];
    }else{
        _apiContext = [context _apiContext];
        [_apiContext Update:self inObject:context];
    }     
}

// gets an instance by ID
// ID must be set in object
// updates and overwrites current properties
-(void) Get:(id)context 
{
    if([context isKindOfClass:[ProxomoApi class]]){
        _apiContext = context;
        [_apiContext Get:self inObject:nil];
    }else{
        _apiContext = [context _apiContext];
        [_apiContext Get:self inObject:context];
    }    
}

// deletes a data instance by ID
// ID must be set in object
-(void) Delete:(id)context 
{
    if([context isKindOfClass:[ProxomoApi class]]){
        _apiContext = context;
        [_apiContext Delete:self inObject:nil];
    }else{
        _apiContext = [context _apiContext];
        [_apiContext Delete:self inObject:context];
    } 
}

#pragma mark - JSON Utilities

- (NSDate *) convertJsonToDate:(NSString *)dateString
{
    NSString* header = @"/Date(";
    uint headerLength = [header length];
    
    NSString*  timestampString;
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:dateString];
    [scanner setScanLocation:headerLength];
    [scanner scanUpToString:@")" intoString:&timestampString];
    
    NSCharacterSet* timezoneDelimiter = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    NSRange rangeOfTimezoneSymbol = [timestampString rangeOfCharacterFromSet:timezoneDelimiter];
    
    if (rangeOfTimezoneSymbol.length!=0) {
        scanner = [[NSScanner alloc] initWithString:timestampString];
        
        NSRange rangeOfFirstNumber;
        rangeOfFirstNumber.location = 0;
        rangeOfFirstNumber.length = rangeOfTimezoneSymbol.location;
        
        NSRange rangeOfSecondNumber;
        rangeOfSecondNumber.location = rangeOfTimezoneSymbol.location + 1;
        rangeOfSecondNumber.length = [timestampString length] - rangeOfSecondNumber.location;
        
        NSString* firstNumberString = [timestampString substringWithRange:rangeOfFirstNumber];
        //NSString* secondNumberString = [timestampString substringWithRange:rangeOfSecondNumber];
        
        unsigned long long firstNumber = [firstNumberString longLongValue];
        //uint secondNumber = [secondNumberString intValue];
        
        NSTimeInterval interval = firstNumber/1000;
        
        return [NSDate dateWithTimeIntervalSince1970:interval];
    }
    
    unsigned long long firstNumber = [timestampString longLongValue];
    NSTimeInterval interval = firstNumber/1000;
    
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

+ (NSString *)dateJsonRepresentation:(NSDate*)date 
{
    NSTimeInterval dateTime;
    NSString *jsonDate;
    dateTime = [date timeIntervalSince1970] * 1000;
    jsonDate = [NSString stringWithFormat:@"/Date(%0.0f+0000)/",dateTime];
    return jsonDate;
}

-(NSMutableDictionary*)proxyForJson
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    const char *ivarName, *typeEncoding;
    id ivarValue;
    char ivarType;
    ptrdiff_t offset;
    int ival = 0;
    long lval = 0;
    double dval;
    NSString *key;
    char cval;
    
    if (ID) [dict setValue:ID forKey:@"ID"]; // inherited do not appear in list?
    for (int i = 0; i < count ; i++)
    {
        ivarName = ivar_getName(ivars[i]);
        key = [NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        typeEncoding = ivar_getTypeEncoding(ivars[i]);
        ivarType = typeEncoding[0];
        
        if (ivarName[0] == '_') {
            continue; // skip fields hidden by starting with _
        }
        
        switch (ivarType) {
            case '@':
                ivarValue = object_getIvar(self, ivars[i]);
                if(!ivarValue || [ivarValue isKindOfClass:[NSNull class]]){
                    //NSLog(@"Empty json value:%@",key);
                    continue;
                }
                if ([ivarValue isKindOfClass:[NSDate class]]) {
                    [dict setValue:[ProxomoObject dateJsonRepresentation:(NSDate*)ivarValue] forKey:key]; 
                }else{
                    [dict setValue:ivarValue forKey:key];
                }
                break;
            case 'd':
                offset = ivar_getOffset(ivars[i]);
                dval = *(double *)((__bridge void*)self + offset);
                [dict setValue:[NSNumber numberWithDouble:dval] forKey:key];
                break;
            case 'i':
                offset = ivar_getOffset(ivars[i]);
                ival = *(int *)((__bridge void*)self + offset);
                [dict setValue:[NSNumber numberWithInteger:ival] forKey:key];
                break;
            case 'l':
                offset = ivar_getOffset(ivars[i]);
                lval = *(long *)((__bridge void*)self + offset);
                [dict setValue:[NSNumber numberWithLong:lval] forKey:key];
                break;
            case 'c':
                offset = ivar_getOffset(ivars[i]);
                cval = *(char *)((__bridge void*)self + offset);
                [dict setValue:[NSNumber numberWithBool:cval] forKey:key];
                break;
            default:
                NSLog(@"Invalid JSON Property proxy %c",ivarType);
                break;
        }
    }
    free(ivars);
    if ([self isKindOfClass:[CustomData class]]) {
        CustomData *cd = (CustomData *)self;
        [dict setValue:cd.TableName forKey:@"TableName"];
    }
    return dict;
}

-(void) updateFromJsonRepresentation:(id)jsonRepresentation 
{
    if(!jsonRepresentation)
        return;
    
    if(![jsonRepresentation isKindOfClass:[NSDictionary class]]) 
        return;
    
    NSString *temp_id = [jsonRepresentation objectForKey:@"ID"];
    if(temp_id){
        // don't loose or overwrite a good ID
        ID = temp_id;
    }
    
    /*
     * Can this loop over Clazz variables - needs optimization
     */
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    const char *ivarName, *typeEncoding;
    id ivarValue;
    char ivarType;
    ptrdiff_t offset;
    int ival = 0;
    long lval = 0;
    char cval = 0;
    double dval = 0;
    NSString *key;
    
    // inherited do not appear in list?
    // attempt to store map of ivar names to ivars to set using the json dictionary
    for (int i = 0; i < count ; i++){
        ivarName = ivar_getName(ivars[i]);
        key = [NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        typeEncoding = ivar_getTypeEncoding(ivars[i]);
        ivarType = typeEncoding[0];

        if (ivarName[0] == '_') {
            if(strcmp(ivarName, "_appData") == 0){
                id appDataJson = [jsonRepresentation objectForKey:@"AppData"];
                if(appDataJson && [appDataJson isKindOfClass:[NSArray class]]) {
                    ProxomoList *pList = [[ProxomoList alloc] init];
                    [pList setListType:APPDATA_TYPE];
                    [pList updateFromJsonRepresentation:appDataJson];
                    object_setIvar(self, ivars[i], pList);
                }
            }
            continue; // skip fields hidden by starting with _
        }
        
        ivarValue = [jsonRepresentation objectForKey:key];
        if(!ivarValue || [ivarValue isKindOfClass:[NSNull class]]){
            //NSLog(@"Empty json key:%@",key);
            continue;
        }
        offset = ivar_getOffset(ivars[i]);
        switch (ivarType) {
            case '@':
                if ([ivarValue isKindOfClass:[NSDate class]]) {
                    object_setIvar(self, ivars[i], [self convertJsonToDate:ivarValue]);
                }else if ([ivarValue isKindOfClass:[NSString class]]) {
                    object_setIvar(self, ivars[i], ivarValue);
                }else if ([ivarValue isKindOfClass:[NSNumber class]]) {
                    object_setIvar(self, ivars[i], ivarValue);
                }else{
                    NSLog(@"Invalid json type %s for %@",class_getName([ivarValue class]), key);
                }
                break;
            case 'd':
                if([ivarValue respondsToSelector:@selector(doubleValue)]){
                    dval = [ivarValue doubleValue];
                    *(double *)((__bridge void*)self + offset) = dval;
                }
                break;               
            case 'i':
                if([ivarValue respondsToSelector:@selector(intValue)]){
                    ival = [ivarValue intValue];
                    *(int *)((__bridge void*)self + offset) = ival;
                }
                break;
            case 'l':
                if([ivarValue respondsToSelector:@selector(longValue)]){
                    lval = [ivarValue longValue];
                    *(int *)((__bridge void*)self + offset) = lval;
                }
                break;
            case 'c':
            case 'B':
                // BOOLEAN
                offset = ivar_getOffset(ivars[i]);
                cval = 0;
                if([ivarValue respondsToSelector:@selector(boolValue)]){
                    cval = [ivarValue boolValue];
                }else if([ivarValue respondsToSelector:@selector(intValue)]){
                    cval = [ivarValue intValue];
                }
                *(char *)((__bridge void*)self + offset) = cval;
                break;
            default:
                NSLog(@"Invalid JSON Property update %c",ivarType);
                break;
        }
    }
    free(ivars);
}

-(void) updateFromJsonData:(NSData*)response 
{
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
    
    if(error != nil){
        NSLog(@"Error reading JSON data %@", error);
    }else{
        [self updateFromJsonRepresentation:dict];
    }
}

-(id)initFromJsonData:(NSData *)jsonData
{
    self = [super init];
    if(self){
        [self updateFromJsonData:jsonData];
    }
    return self;
}

-(id)initFromJsonRepresentation:(NSDictionary*)jsonRepresentation
{
    self = [super init];
    if(self){
        [self updateFromJsonRepresentation:jsonRepresentation];
    }
    return self;
}

#pragma mark - API Delegate

-(void) handleResponse:(NSData*)response requestType:(enumRequestType)requestType responseCode:(NSInteger)code responseStatus:(NSString*) status
{
    responseCode = code;
    restResponse = status;
    if(requestType == GET){
        [self updateFromJsonData:response];
    } else if (requestType == POST){
        NSError *error;
        NSString *id = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
        if(id != nil && error == nil){
            ID = id;
        }else{
            NSLog(@"Warning - invalid ID returned from server");
        }
    }
    
    if([appDelegate respondsToSelector:@selector(asyncObjectComplete:proxomoObject:)]){
        [appDelegate asyncObjectComplete:(responseCode==200) proxomoObject:self];
    }
}

-(void) handleError:(NSData*)response requestType:(enumRequestType)requestType responseCode:(NSInteger)code responseStatus:(NSString*) status
{
    requestType = NONE;
    responseCode = code;
    restResponse = status;
    if([appDelegate respondsToSelector:@selector(asyncObjectComplete:proxomoObject:)]){
        [appDelegate asyncObjectComplete:FALSE proxomoObject:self];
    }
}


@end
