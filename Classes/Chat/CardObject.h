//
//  CardObject.h
//  Volley
//
//  Created by Kyle Bendelow on 2/23/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CardCellView.h"


@interface CardObject : NSObject

@property PFObject *set;
@property NSString *setID;
@property PFObject *room;
@property NSString *roomID;
@property PFObject *customChatRoom;
@property NSString *title;
@property BOOL unreadStatus;
@property int numberOfMessages;
@property UIImage *imageOne;
@property UIImage *imageTwo;
@property PFUser *userWhoCreatedCard;
@property CardCellView *chatVC;
@property NSDate *dateUpdated;
@property int *numberOfTextMessages;
@property NSMutableArray *photosArray;
@property NSMutableArray *messagesArray;
@property NSNumber *numberFromDateToSortWith;


- (instancetype)initWithChatObject:(PFObject *)object;
-(void)modifyCardWith:(PFObject *)object;
+ (void)retrieveResultsWithSearchTerm:(PFObject *)chatRoom withCompletion:(void (^)(NSArray *results))complete;
- (void)getPicsForCardwithPics:(void (^)(BOOL pics))complete;
- (void)checkForUnreadUsers:(void (^)(BOOL finished))complete;


-(void)createVCForCard;

@end
