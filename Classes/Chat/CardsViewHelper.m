//
//  CardsViewHelper.m
//  Volley
//
//  Created by Kyle Bendelow on 2/23/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "CardsViewHelper.h"

@interface CardsViewHelper ()

@end

@implementation CardsViewHelper

-(void)getPicsWith:(CardObject*)card
{
    long tempcount = card.photosArray.count;
    int count = (int)tempcount;
    
    if (count == 0)
    {
        NSLog(@"no images");
        card.imageOne = [UIImage imageNamed:@"Vollie-icon"];
        card.imageTwo = [UIImage imageNamed:@"Vollie-icon"];
    }
    else if (count == 1)
    {
        PFObject *tempPhoto = card.photosArray[0];
        PFFile *thumbnail = [tempPhoto objectForKey:@"thumbnail"];
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"downloaded 1 pic");
                 card.imageOne = [UIImage imageWithData:data];
                 card.imageTwo = [UIImage imageNamed:@"Vollie-icon"];
             }
         }];
    }
    else
    {
        PFObject *firstPhoto = card.photosArray[count-2];
        PFFile *firstThumbnailData = [firstPhoto objectForKey:@"thumbnail"];
        [firstThumbnailData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 card.imageOne = [UIImage imageWithData:data];
             }
         }];
        PFObject *secondPhoto = card.photosArray[count-1];
        PFFile *secondPhotoFile = [secondPhoto objectForKey:@"thumbnail"];
        [secondPhotoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"downloaded 2 pics");
                 card.imageTwo = [UIImage imageWithData:data];
             }
         }];
    }
}

@end
