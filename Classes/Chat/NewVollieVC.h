//
//  NewVollieVC.h
//  Volley
//
//  Created by Kyle on 6/19/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterScrollView.h"
#import <Parse/Parse.h>
#import "ParseVolliePackage.h"

@protocol NewVollieDelegate <NSObject>
-(void) newVollieDismissed:(NSString *)textForCam andPhotos:(NSMutableArray*)photosArray;
@end

@interface NewVollieVC : UIViewController

@property (nonatomic, assign) id<NewVollieDelegate> textDelegate;

@property NSString *textFromLastVC;
@property NSString *message;
@property NSMutableArray *photosArray;
@property MasterScrollView *scrollView;
@property BOOL comingFromCamera;
@property BOOL showingCamera;
@property PFObject *whichRoom;
@property ParseVolliePackage *package;

@end
