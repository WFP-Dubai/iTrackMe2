//
//  AppDelegate.h
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//
@import UIKit;

#import "Location.h"


@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) MainViewController *mainViewController;

@property (strong, nonatomic) NSString * userName;
@property (strong,nonatomic) NSString * serverURL;
@property  (strong,nonatomic) NSNumber * distanceFilter;
@property   (strong,nonatomic) NSNumber * timeDeltaFilter;
@property   (strong,nonatomic) NSNumber * timeStationaryUpdate;

/* Walk Slow Fast / Timer DistanceFilter */
@property   (strong,nonatomic) NSNumber * WalkTimer;
@property   (strong,nonatomic) NSNumber * SlowTimer;
@property   (strong,nonatomic) NSNumber * FastTimer;
@property   (strong,nonatomic) NSNumber * WalkDistanceFilter;
@property   (strong,nonatomic) NSNumber * SlowDistanceFilter;
@property   (strong,nonatomic) NSNumber * FastDistanceFilter;


@end
