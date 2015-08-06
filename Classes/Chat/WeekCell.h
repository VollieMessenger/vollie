//
//  WeekCell.h
//  Volley
//
//  Created by Kyle Bendelow on 8/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface WeekCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *imageViewOneBig;
@property (weak, nonatomic) IBOutlet PFImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet PFImageView *imageViewThree;
@property (weak, nonatomic) IBOutlet PFImageView *imageViewFour;
@property (weak, nonatomic) IBOutlet PFImageView *imageViewFive;
@property NSMutableArray *imageViewArray;
@property (weak, nonatomic) IBOutlet UIView *fourPicUIView;
@property (weak, nonatomic) IBOutlet UIView *topSpacerView;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

-(void)formatCell;

@end
