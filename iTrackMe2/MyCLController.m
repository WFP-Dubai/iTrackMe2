//
//  MyCLController.m
//  iTrackMe
//
//  Created by Tobias Carlander on 16/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//
// Toby
#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize  delegate = _delegate;
@synthesize running;


- (id) init {
    self = [super init];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    int DistanceFilter = [appDelegate.distanceFilter intValue];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self; // send loc updates to myself
        self.locationManager.distanceFilter = DistanceFilter;
//        self.locationManager.purpose = @"This is needed to be able to track your movements, and send them to the Tracking Server";
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    [self.delegate locationUpdate:newLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

-(void)locationManagerStop

{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    running = FALSE;
}
-(void)locationManagerStart

{
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];    
    running = TRUE;
}

-(void) locationToggler{
    if (!self.running){
        [self locationManagerStart];
    }else{
        [self locationManagerStop];
    }
}


@end