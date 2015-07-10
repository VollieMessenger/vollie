//
//  ChatForCellVC.h
//  Volley
//
//  Created by Kyle on 7/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CardChatVC.h"

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import "CustomCameraView.h"

@interface ChatForCellVC : CardChatVC <JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate>

-(id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages;

@property PFObject *room;
@property BOOL isFavoritesSets;
@property PFObject *album;
@property NSString *setIDforCardCheck;

@end
