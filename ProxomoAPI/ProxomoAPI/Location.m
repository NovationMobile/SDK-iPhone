//
//  Locations.m
//  PROXOMO
//
//  Created by Charisse Dirain on 10/26/11.
//  Copyright (c) 2011 Proxomo. All rights reserved.
//

#import "Location.h"
#import "AppData.h"

@implementation Location
@synthesize Name;
@synthesize LocationSecurity;
@synthesize LocationID;
@synthesize Latitude;
@synthesize Longitude;
@synthesize Address1;
@synthesize Address2;
@synthesize City;
@synthesize State;
@synthesize Zip;
@synthesize CountryName;
@synthesize CountryCode;


#pragma mark - API Delegate

-(enumObjectType) objectType{
    return LOCATION_TYPE;
}

-(NSString *) objectPath{
    return @"location";
}


#pragma mark - Search
-(NSArray*)appData{
    return [_appData arrayValue];
}
-(NSArray*)locations{
    return [_locations arrayValue];
}

-(NSArray*)byAddress:(NSString *)address apiContext:(ProxomoApi *)context useAsync:(BOOL)useAsync{
    _locations = [[ProxomoList alloc] init];
    [_locations setAppDelegate:appDelegate];
    _apiContext = context;
    [context Search:_locations searchUrl:@"s/search/address" searchUri:address forListType:LOCATION_TYPE useAsync:useAsync inObject:nil];
    return [_locations arrayValue];
}

-(NSArray*)byIP:(NSString*)ip apiContext:(ProxomoApi *)context useAsync:(BOOL)useAsync{
    _locations = [[ProxomoList alloc] init];
    [_locations setAppDelegate:appDelegate];
    _apiContext = context;
    [context Search:_locations searchUrl:@"s/search/ip" searchUri:ip forListType:LOCATION_TYPE useAsync:useAsync inObject:nil];
    return [_locations arrayValue];
}

-(NSArray *) byLatitude:(double)latitude byLogitude:(double)longitude apiContext:(ProxomoApi*)context useAsync:(BOOL)useAsync{
    NSString *searchUrl = [NSString stringWithFormat:@"s/search/latitude/%f/longitude",
                           latitude];
    NSString *searchUri = [NSString stringWithFormat:@"%f",
                           longitude];
    _locations = [[ProxomoList alloc] init];
    [_locations setAppDelegate:appDelegate];
    _apiContext = context;
    [context Search:_locations searchUrl:searchUrl searchUri:searchUri forListType:LOCATION_TYPE useAsync:useAsync inObject:nil];
    return [_locations arrayValue];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", Name, Address1, City, State, Zip];
}


@end
