//
//  FivePicsFavCell.m
//  Volley
//
//  Created by Kyle Bendelow on 8/3/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "FivePicsFavCell.h"

@implementation FivePicsFavCell
@synthesize imageViewOne;
@synthesize imageViewTwo;
@synthesize imageViewThree;
@synthesize imageViewFour;
@synthesize imageViewFive;

- (void)awakeFromNib {
    // Initialization code
}

-(void)formatCell
{
    self.backgroundColor = [UIColor clearColor];
    
    self.imageViewArray = [[NSMutableArray alloc] initWithObjects:self.imageViewOne, self.imageViewTwo, self.imageViewThree, self.imageViewFour, self.imageViewFive, nil];
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
