//
//  MainViewController.m
//  iTrackMe2
//
//  Created by Tobias Carlander on 17/08/2011.
//  Copyright (c) 2011 Tobias Carlander. All rights reserved.
//

#import "MainViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation MainViewController
@synthesize uploadPhotoButton;
@synthesize cameraButton;
@synthesize startStopButton;
@synthesize TheMap;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize popoverController;
@synthesize managedObjectModel =  __managedObjectModel;
@synthesize myQueue;




- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) 
    {
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    locationController = [[MyCLController alloc] init];
    locationController.delegate = self;
    locationController.locationManager.distanceFilter = [appDelegate.distanceFilter doubleValue];
    [locationController locationManagerStart];
    if (__managedObjectContext == nil) 
    { 
        __managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] ; 
    }
    if (__managedObjectModel==nil) 
    {
        __managedObjectModel = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectModel] ; 
    }
    [NSTimer scheduledTimerWithTimeInterval:60
                                     target:self
                                   selector:@selector(locationUpdateTimer:)
                                   userInfo:nil
                                    repeats:NO];
    myQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
}

- (void)viewDidUnload
{
    [self setTheMap:nil];
    [self setUploadPhotoButton:nil];
    [self setCameraButton:nil];
    [self setStartStopButton:nil];
    precisionLable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)locationUpdate:(CLLocation *)location 
{
   
    CLLocationAccuracy accuracy = location.horizontalAccuracy;
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;

    locationLabelLat.text =  [NSString stringWithFormat:@"Lat: %g",latitude] ;
    locationLabelLong.text = [NSString stringWithFormat:@"Long: %g",longitude] ;
    precisionLable.text =    [NSString stringWithFormat:@"±%.0fm",accuracy];
    
    // TODO: Add Distance and Speed change

    MKCoordinateRegion region;
	region.center=location.coordinate;
    MKCoordinateSpan span;
	span.latitudeDelta=.01;
	span.longitudeDelta=.01;
	region.span=span;
    if (location.speed <= 20 ){
        NSLog(@"Walking");
        NSLog(@"%f",locationController.locationManager.distanceFilter);
        if(locationController.locationManager.distanceFilter != 100){
            locationController.locationManager.distanceFilter = 100;
            [appDelegate setTimeStationaryUpdate:@5];
            [appDelegate setTimeDeltaFilter:@2];
        }
        
    }else if (location.speed > 20 && location.speed < 60){
        NSLog(@"Speeding");
        NSLog(@"%f",locationController.locationManager.distanceFilter);
        if(locationController.locationManager.distanceFilter != 500){
            locationController.locationManager.distanceFilter = 500;
            [appDelegate setTimeStationaryUpdate:@15];
            [appDelegate setTimeDeltaFilter:@7];
        }
    }else if (location.speed >= 60){
        NSLog(@"Speeding");
        NSLog(@"%f",locationController.locationManager.distanceFilter);
        if(locationController.locationManager.distanceFilter != 2000){
            locationController.locationManager.distanceFilter = 2000;
            [appDelegate setTimeStationaryUpdate:@5];
            [appDelegate setTimeDeltaFilter:@2];
        }
    }
    
    [self addEvent];
    [TheMap setRegion:region animated:TRUE];
}

- (void)locationError:(NSError *)error 
{
    locationLabelLat.text = [error description];
}

- (IBAction)locationToggle:(id)sender
{
    
    if (!locationController.running)
    {
        startStopButton.title=@"Stop";
        [TheMap setShowsUserLocation:YES];
    }else{
        startStopButton.title=@"Start";
        [TheMap setShowsUserLocation:NO];
    }
    [self sendData];
    [locationController locationToggler];
}


- (IBAction)uploadPhoto:(UIBarButtonItem *)sender
{
    BOOL ran = FALSE;
    if (!locationController.running)
    {
        [locationController locationToggler];
        ran = YES;
    }

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) 
    {
        return; 
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    picker.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        NSLog(@"iPadding");
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popoverController = popover;
        [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //        [(UIBarButtonItem *)sender setEnabled:NO];
    }else{
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
    if(ran){
        [locationController locationToggler];
    }
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(BOOL)pushImageToServer:(UIImage *)imageToPost
{
    NSString * userName = appDelegate.userName;
    NSString * baseURL = appDelegate.serverURL;
    
    UIImage *smallImage = [self imageWithImage:imageToPost scaledToSize:CGSizeMake(290, 390)];
    
    NSString * description = @"Sim Description";
    CLLocation *location = locationController.locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];

    NSString * latitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString * longitude = [NSString stringWithFormat:@"%f",coordinate.longitude];

    NSData *imageData = UIImagePNGRepresentation(smallImage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@incident/",baseURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    //NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@\r\n",boundary];
   // [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];//
    NSMutableData *body = [NSMutableData data];
    // file
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"image\"; filename=\"%@.png\"\r\n", userName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",userName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"description\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",description] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"POINT(%@ %@)", longitude, latitude] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Image Return String: %@", returnString);
    
    return NO;
}


- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    BOOL saved = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * myImage = info[UIImagePickerControllerOriginalImage];
    if (myImage) {
        saved = [self pushImageToServer:myImage];
         //NSLog(@"Popped %c", saved);
    }else{
        //NSLog(@"Popped %@", myImage);
    }
    //Do Image save

    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    // Dismiss the image selection and close the program
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    //NSLog(@"Dissmissed picker");
    [[Crashlytics sharedInstance] crash];
    
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)Controller{
    
    //NSLog(@"Dissmissed picker");
    popoverController=nil;
    
}


- (void)addEvent
{
    
    CLLocation *location = locationController.locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSDate *date = [location timestamp];
    NSNumber *speed = @(location.speed);
    if ([speed   isEqual: @-1]){
        speed = @0;
    }
    
    Location *dLocation = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[self managedObjectContext]];
    [dLocation setLatitude:@(coordinate.latitude)];
    [dLocation setLongitude:@(coordinate.longitude)];
    [dLocation setDateOccured:date];
    [dLocation setAltitude:@(location.altitude)];
    [dLocation setAngle:@(location.course)];
    [dLocation setComment:@""];
    [dLocation setIconID:@"1"];
    [dLocation setSpeed:speed];
    [dLocation setUploaded:@0];
    [dLocation setAccuracy:@(location.horizontalAccuracy)];

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // Handle the error.
    }else{
        
    }
    dispatch_async([self myQueue], ^{   
        [self sendData];
    });
    
}

-(void)locationUpdateTimer:(NSTimer *)timer{
    NSLog(@"Timer Fired");
    
    CLLocation *location = locationController.locationManager.location;
    NSTimeInterval secondsSinceUpdate = -[location timestamp].timeIntervalSinceNow;
    NSLog(@"%f",secondsSinceUpdate);
    if ([@(secondsSinceUpdate) intValue]> [appDelegate.timeDeltaFilter intValue]*60 ){
        NSLog(@"Do It");
        [locationController.locationManager stopUpdatingLocation ];
        [locationController.locationManager startUpdatingLocation ];
    }else{
        
    }
    
    [NSTimer scheduledTimerWithTimeInterval:[appDelegate.timeStationaryUpdate intValue]*60
                                     target:self
                                   selector:@selector(locationUpdateTimer:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)sendData
{
   /* if(appDelegate.userName == nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Username Set"
                                                        message:@"Your need to set the username in the settings to use the app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }*/
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init] ;
    [moc setPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator]];
    NSManagedObjectModel *mom = [[moc persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *fetchRequest = [ mom fetchRequestTemplateForName:@"GetAllNotUploaded"];
    NSFetchRequest *deleteRequest = [mom fetchRequestTemplateForName:@"GetAllUploaded"];
    NSDate *timeStamp = [NSDate date];
    NSError *error = nil;
    NSArray *fobjects = [moc executeFetchRequest:fetchRequest error:&error];

    for ( Location *dLocation in fobjects)
    {
        if([self pushObject:dLocation])
        {
            [dLocation setUploaded:@1];
        }
    }

    [moc  save:&error];
    
    fobjects = [moc executeFetchRequest:deleteRequest error:&error];
    for ( Location *dLocation in fobjects)
    {
        //Location *dLocation = (Location *) ob;
        NSManagedObject *eventToDelete = [moc objectWithID:dLocation.objectID];
        [eventToDelete.managedObjectContext deleteObject:eventToDelete];
    }
    locationLabelTime.text = [NSString stringWithFormat:@"Last Update: %@",timeStamp];
  //  NSLog(@"%@",locationLabelTime.text);
    [moc  save:&error];
}

-(BOOL)pushObject:(Location *)location
{
    // construct url and send it to server
    // /trackme/requests.php?a=upload&u=wgonzalez&p=wfpdubai&lat=25.18511038&long=55.29178735&do=2011-2-3%2013:12:3&tn=wgonzalez&alt=7&ang=&sp=&acc&db=8
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString * userName = appDelegate.userName;
    NSString * baseURL = appDelegate.serverURL;
    NSString * latitde = [NSString stringWithFormat:@"%@", location.Latitude];
    NSString * longitude = [NSString stringWithFormat:@"%@", location.Longitude];
    NSString * altitude = [NSString stringWithFormat:@"%@", location.Altitude];
    NSString * angle = [NSString stringWithFormat:@"%@", location.Angle];
    NSString * datedone = [dateFormatter stringFromDate:location.DateOccured];
    NSString * speed = [NSString stringWithFormat:@"%@", location.Speed];
    NSString * accuracy = [NSString stringWithFormat:@"%@", location.accuracy];
    
    NSString * fullUrl = [NSString stringWithFormat:@"%@requests.php?a=upload&u=%@&p=wfpdubai&lat=%@&long=%@&do=%@&tn=%@&alt=%@&ang=%@&sp=%@&acc=%@&db=8"
                          ,baseURL,userName,latitde,longitude,datedone,userName,altitude,angle,speed,accuracy];
    
    fullUrl = [fullUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
   // NSLog(@"%@",fullUrl);
    NSURL * serverUrl =  [NSURL URLWithString:fullUrl];
    NSURLRequest *theRequest=[
                              NSURLRequest requestWithURL:serverUrl
                                              cachePolicy:NSURLCacheStorageNotAllowed
                                          timeoutInterval:2
                              ];
    NSError *error = nil;
    NSURLResponse  *response = nil;
    NSData *dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    NSString * stringReply = (NSString *)[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];    
    if ([stringReply isEqualToString:@"Result:0"] || [stringReply isEqualToString:@"Result:2"] ) {
        return TRUE;
    } else {
        return FALSE;
    }
    return TRUE;
}

- (IBAction)takePhoto:(id)sender {

}

- (IBAction)tagLocation:(id)sender {
    
    
}



@end



