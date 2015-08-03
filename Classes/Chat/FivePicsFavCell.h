//
//  FivePicsFavCell.h
//  Volley
//
//  Created by Kyle Bendelow on 8/3/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "UIColor+JSQMessages.h"
//#import "JSQMessagesCollectionView.h"
#import "JSQMessagesViewController.h"
#import "VollieCardData.h"

@interface FivePicsFavCell : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *imageViewOne;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewTwo;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewThree;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewFour;
@property (strong, nonatomic) IBOutlet PFImageView *imageViewFive;


@property (strong, nonatomic) IBOutlet UIView *cardView;

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData;
-(void)formatCell;
@property (strong, nonatomic) IBOutlet UIView *viewForChatVC;

@property NSMutableArray *imageViewArray;




@end
