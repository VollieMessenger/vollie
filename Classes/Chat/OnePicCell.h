//
//  OnePicCell.h
//  Volley
//
//  Created by Kyle on 7/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h> 
#import "UIColor+JSQMessages.h"
//#import "JSQMessagesCollectionView.h"
#import "JSQMessagesViewController.h"
#import "VollieCardData.h"


@interface OnePicCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PFImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *cardView;

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData;
-(void)formatCell;
@property (strong, nonatomic) IBOutlet UIView *viewForChatVC;


@end
