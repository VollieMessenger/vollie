//
//  PhotoCell.m
//  Volley
//
//  Created by Kyle Bendelow on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

-(void)fillImageViewWithParse:(PFFile *)pictureObject
{
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    
    [pictureObject getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         if (!error)
         {
             self.imageView.image = [UIImage imageWithData:data];
         }
         else
         {
             self.imageView.image = [UIImage imageNamed:@"Vollie-icon"];
         }
     }];
}

@end
