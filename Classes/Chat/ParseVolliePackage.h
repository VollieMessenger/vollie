//
//  StreetLegal.h
//  Volley
//
//  Created by Kyle on 7/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol RefreshMessagesDelegate <NSObject>
-(void)reloadAfterMessageSuccessfullySent;
@end

@interface ParseVolliePackage : NSObject

-(void)sendPhotosWithPhotosArray:(NSMutableArray*)photosArray andText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID;

-(void)checkForTextAndSendItWithText:(NSString*)text andRoom:(PFObject *)roomNumber andSet:(PFObject*)setID;

@property (nonatomic, assign) id<RefreshMessagesDelegate> refreshDelegate;

@property int countDownForLastPhoto;
@property NSMutableArray *savedPhotoObjects;
@property NSMutableArray *savedImageFiles;
@property PFObject *lastPicFromPackage;


@end
