//
//  OnePicCellNew.h
//  Volley
//
//  Created by Kyle Bendelow on 10/26/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "VollieCardData.h"

@interface OnePicCellNew : UITableViewCell

@property (strong, nonatomic) IBOutlet PFImageView *imageViewOne;
@property (strong, nonatomic) IBOutlet UIView *cardView;

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData;
-(void)formatCell;
@property (strong, nonatomic) IBOutlet UIView *viewForChatVC;

@end
