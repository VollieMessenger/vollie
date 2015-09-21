//
//  CustomChatView.h
//  Volley
//
//  Created by benjaminhallock@gmail.com on 12/4/14.
//  Copyright (c) 2014 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import "CustomCameraView.h"

@interface CustomChatView : JSQMessagesViewController <JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate>

-(id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages andActualSet:(PFObject *)actualSet;

- (id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor;

- (id)initWithSet:(PFObject*)set andUserChatRoom:(PFObject*)userChatRoom;


@property PFObject *room;
@property PFObject *userChatRoom;
@property BOOL isFavoritesSets;
@property PFObject *album;
@property NSString *setIDforCardCheck;
@property PFObject *setChat;

@end
