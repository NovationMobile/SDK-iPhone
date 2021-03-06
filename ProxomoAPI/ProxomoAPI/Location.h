//
//  Locations.h
//  PROXOMO
//
//  Created by Charisse Dirain on 10/26/11.
//  Copyright (c) 2011 Proxomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProxomoObject.h"
#import "ProxomoList.h"

typedef enum {
    OPEN_LOCATION = 0,
    PRIVATE_LOCATION = 1
} enumLocationSecurity;

@interface Location : ProxomoObject {
    NSString *Name;
    enumLocationSecurity LocationSecurity; // Defines security scope for location   
    NSString *LocationID;
    NSString *LocationType; // Developer-defined type identifier
    NSNumber *Latitude;
    NSNumber *Longitude;
    NSString *Address1;
    NSString *Address2;
    NSString *City;
    NSString *State;
    NSString *Zip;
    NSString *CountryName;
    NSString *CountryCode; 
    NSString *PersonID;     // Associates location with one person
    ProxomoList *_appData;
    ProxomoList *_locations;
}

@property (nonatomic, strong) NSString *Name;
@property (nonatomic) enumLocationSecurity LocationSecurity;
@property (nonatomic, strong) NSString *LocationID;
@property (nonatomic, strong) NSNumber *Latitude;
@property (nonatomic, strong) NSNumber *Longitude;
@property (nonatomic, strong) NSString *Address1;
@property (nonatomic, strong) NSString *Address2;
@property (nonatomic, strong) NSString *City;
@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSString *Zip;
@property (nonatomic, strong) NSString *CountryName;
@property (nonatomic, strong) NSString *CountryCode;
@property (nonatomic, strong) NSString *PersonID;
@property (nonatomic, strong) NSString *LocationType;

-(ProxomoList*)byAddress:(NSString*)address apiContext:(id)context; 
-(ProxomoList*)byIP:(NSString*)ip apiContext:(id)context; 
-(ProxomoList *)byLatitude:(double)latitude byLogitude:(double)longitude apiContext:(ProxomoApi*)context;
-(NSArray*)locations;
-(NSArray*)appData;

@end
