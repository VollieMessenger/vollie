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

-(void)fillPicsWithTop5PicsFromHighlight:(HighlightData*)highlight
{
    int i = 0;
    for (Set *set in highlight.sortedSets)
    {
        PFObject *actualSet = set.set;
        if (i < 6)
        {
            NSLog(@"%i", set.numberOfResponses);
            PFObject *lastPicture = [actualSet objectForKey:@"lastPicture"];
            PFFile *thumbnail = [lastPicture objectForKey:@"thumbnail"];
            [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 if (!error)
                 {
                     PFImageView *imageView = self.imageViewArray[i];
                     imageView.image = [UIImage imageWithData:data];
//                     NSLog(@"Picture %i has %@ responses", i, set.numberOfResponses);
                 }
                 else
                 {
                     NSLog(@"i had an error loading a picture");
                 }
             }];
            i++;
//            NSLog(@"%i", i);
        }
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
