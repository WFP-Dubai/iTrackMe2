//
//  MainViewController.h
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

#import "AppDelegate.h"
#import "MyCLController.h"
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIImagePickerController.h>



@interface MainViewController : UIViewController < MyCLControllerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate>{
    AppDelegate *appDelegate;

    MyCLController *locationController;
    IBOutlet UILabel *locationLabelLat;
    IBOutlet UILabel *locationLabelLong;
    IBOutlet UILabel *locationLabelTime;
    IBOutlet UIButton *statusLabel;
    MKMapView *TheMap;
    __unsafe_unretained IBOutlet UILabel *precisionLable;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong,nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *uploadPhotoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *startStopButton;
@property (strong, nonatomic) IBOutlet MKMapView *TheMap;
@property   dispatch_queue_t myQueue;


//- (IBAction)showInfo:(id)sender;
- (IBAction)locationToggle:(id)sender;
- (IBAction)uploadPhoto:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)tagLocation:(id)sender;


- (void)addEvent;
- (void)sendData;
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
- (BOOL)pushObject:(Location *)location;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
