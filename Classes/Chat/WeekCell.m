//
//  WeekCell.m
//  Volley
//
//  Created by Kyle Bendelow on 8/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "WeekCell.h"

@implementation WeekCell
@synthesize imageViewOneBig;
@synthesize imageViewTwo;
@synthesize imageViewThree;
@synthesize imageViewFour;
@synthesize imageViewFive;

-(void)formatCell
{
    self.backgroundColor = [UIColor clearColor];
    self.fourPicUIView.backgroundColor = [UIColor clearColor];
    self.topSpacerView.backgroundColor = [UIColor clearColor];
    
    self.imageViewArray = [[NSMutableArray alloc] initWithObjects:self.imageViewOneBig, self.imageViewTwo, self.imageViewThree, self.imageViewFour, self.imageViewFive, nil];
    
    for (PFImageView *imageview in self.imageViewArray)
    {
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 10;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
