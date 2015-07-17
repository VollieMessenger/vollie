//
//  NewJSQTestVCViewController.h
//  Volley
//
//  Created by Kyle on 7/16/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "TestJSQ_VC.h"
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import "CustomCameraView.h"

//#import "DemoModelData.h"
//#import "NSUserDefaults+DemoSettings.h"

@interface NewJSQTestVCViewController : TestJSQ_VC <JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, UIScrollViewDelegate>

//-(id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages;

-(id)initWithSetId:(NSString *)setId andMessages:(NSArray *)messages;

//- (id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor;

@property PFObject *room;
@property BOOL isFavoritesSets;
@property PFObject *album;
@property NSString *setIDforCardCheck;



@end
