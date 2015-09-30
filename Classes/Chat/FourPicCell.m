//
//  FourPicCell.m
//  Volley
//
//  Created by Kyle on 7/13/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "FourPicCell.h"

@implementation FourPicCell
@synthesize imageViewOne;
@synthesize imageViewTwo;
@synthesize imageViewThree;
@synthesize imageViewFour;

- (void)awakeFromNib {
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
    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.76 alpha:1.000].CGColor;
//    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.829 alpha:1.000].CGColor;
    self.cardView.layer.borderWidth = 1;
    self.cardView.layer.masksToBounds = YES;

    self.imageViewArray = [[NSMutableArray alloc] initWithObjects:self.imageViewOne, self.imageViewTwo, self.imageViewThree, self.imageViewFour, nil];

    for (PFImageView *imageview in self.imageViewArray)
    {
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 10;
    }

}

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData
{
    int i = 0;
    for (PFObject *photo in vollieCardData.photosArray)
    {
        //        PFObject *photo = vollieCardData.photosArray.firstObject;
        //        NSLog(@"%@", photo);
        PFFile *thumbnail = [photo objectForKey:@"thumbnail"];
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 PFImageView *imageView = self.imageViewArray[i];
                 imageView.image = [UIImage imageWithData:data];
             }
         }];
        i++;
    }
}

@end
