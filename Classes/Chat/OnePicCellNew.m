//
//  OnePicCellNew.m
//  Volley
//
//  Created by Kyle Bendelow on 10/26/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "OnePicCellNew.h"

@implementation OnePicCellNew

- (void)awakeFromNib {
    // Initialization code
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
    
    self.viewForChatVC.backgroundColor = [UIColor purpleColor];
    
    self.imageViewOne.layer.masksToBounds = YES;
    self.imageViewOne.layer.cornerRadius = 10;
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
//                 PFImageView *imageView = self.imageViewArray[i];
                 self.imageViewOne.image = [UIImage imageWithData:data];
             }
         }];
        i++;
    }
}

@end
