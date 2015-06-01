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

-(id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages;

- (id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor;

@property PFObject *room;
@property BOOL isFavoritesSets;
@property PFObject *album;
@end
