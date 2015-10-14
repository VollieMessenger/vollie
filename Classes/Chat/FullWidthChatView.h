//
//  FullWidthChatView.h
//  Volley
//
//  Created by Kyle Bendelow on 10/13/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "FullWidthChat.h"
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import "CustomCameraView.h"

@interface FullWidthChatView : FullWidthChat <JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate>

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
