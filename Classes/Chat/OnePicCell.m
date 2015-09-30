//
//  OnePicCell.m
//  Volley
//
//  Created by Kyle on 7/10/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "OnePicCell.h"

@implementation OnePicCell

@synthesize imageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)formatCell
{
    self.backgroundColor = [UIColor clearColor];
    self.cardView.backgroundColor = [UIColor whiteColor];
//    self.cardView.layer.cornerRadius = 10;
//    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.829 alpha:1.000].CGColor;
    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.76 alpha:1.000].CGColor;

    self.cardView.layer.borderWidth = 1;
    self.cardView.layer.masksToBounds = YES;

    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 10;
}

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData
{
    PFObject *photo = vollieCardData.photosArray.firstObject;
//    NSLog(@"%@", photo);
    PFFile *thumbnail = [photo objectForKey:@"thumbnail"];
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
    {
        if (!error)
        {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
    
    if (vollieCardData.unreadStatus == true)
    {
//        self.notificationDot.image = [UIImage imageNamed:@"Camera Icon"];
        self.notificationDot.backgroundColor = [UIColor orangeColor];
        NSLog(@"should have changed to orange");
    }
    else
    {
//        NSLog(@"no unread messages");
    }
}

@end
