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
        [imageview setImage:[UIImage imageNamed:@"Vollie-icon"]];

    }
}

-(void)fillPicsWithTop5PicsFromHighlight:(HighlightData*)highlight
{
//    Set *setOne = highlight.sortedSets[1];
//    PFObject *actualSetOne = setOne.set;
////    NSLog(@"%@", actualSetOne);
//    PFObject *lastPicture = [actualSetOne objectForKey:@"lastPicture"];
//    NSLog(@"%@", lastPicture);
//    PFFile *thumbnail = [lastPicture objectForKey:@"thumbnail"];
//    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
//    {
//        if(!error)
//        {
//            self.imageViewOneBig.image = [UIImage imageWithData:data];
//            NSLog(@"i loaded the data");
//        }
//        else
//        {
//            
//        }
//    }];
    int i = 0;
    for (Set *set in highlight.sortedSets)
    {
        PFObject *actualSet = set.set;
//        NSLog(@"%@", actualSet);
        if (i < 6)
        {
//            NSLog(@"%i", set.numberOfResponses);
            PFObject *lastPicture = [actualSet objectForKey:@"lastPicture"];
//            NSLog(@"%@", lastPicture);
            if ([lastPicture objectForKey:@"thumbnail"])
            {
                PFFile *thumbnail = [lastPicture objectForKey:@"thumbnail"];
                [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
                 {
                     if (!error)
                     {
                         PFImageView *imageView = self.imageViewArray[i];
                         imageView.image = [UIImage imageWithData:data];
//                         NSLog(@"%@", lastPicture);
//                              NSLog(@"Picture %i has %@ responses", i, set.numberOfResponses);
                     }
                     else
                     {
                         NSLog(@"i had an error loading a picture");
                     }
                 }];
            }
            else
            {
//                PFImageView *imageView = self.imageViewArray[i];
//                imageView.image = [UIImage imageNamed:@"Vollie-icon"];
//                NSLog(@"corrupted photo in highlights view");
            }
            i++;
//            NSLog(@"Picture %i has %i responses", i, set.numberOfResponses);
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
