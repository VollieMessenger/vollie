//
//  CardCellView.h
//  Volley
//
//  Created by Kyle on 6/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "CardVC.h"

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import "CustomCameraView.h"

@interface CardCellView : CardVC <JSQMessagesCollectionViewDelegateFlowLayout, JSQMessagesCollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate>

-(id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor andPictures:(NSArray *)pictures andComments:(NSArray *)messages;

//- (id)initWithSetId:(NSString *)setId andColor:(UIColor *)backgroundColor;

@property PFObject *room;
@property BOOL isFavoritesSets;
@property PFObject *album;
@property NSString *setIDforCardCheck;



@end
