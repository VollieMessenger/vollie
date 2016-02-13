//
//  DynamicCardCell.m
//  Volley
//
//  Created by Kyle Bendelow on 2/12/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "DynamicCardCell.h"

@implementation DynamicCardCell

@synthesize imageViewOne;
@synthesize imageViewTwo;

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
    //    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.829 alpha:1.000].CGColor;
    self.cardView.layer.borderColor = [UIColor colorWithWhite:0.76 alpha:1.000].CGColor;
    self.cardView.layer.borderWidth = 1;
    self.cardView.layer.masksToBounds = YES;
    
    self.viewForChatVC.backgroundColor = [UIColor purpleColor];
    
    self.imageViewArray = [[NSMutableArray alloc] initWithObjects:self.imageViewOne, self.imageViewTwo, nil];
    
    for (PFImageView *imageview in self.imageViewArray)
    {
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 10;
    }
}

-(void)fillPicsWithVollieCardData:(VollieCardData*)vollieCardData
{
    NSLog(@"Created card in MomentsVC");
    if (vollieCardData.titleForCard)
    {
        self.titleLabel.text = vollieCardData.titleForCard;
    }
    else
    {
        self.titleLabel.text = @"";
    }
    
    long tempcount = vollieCardData.photosArray.count;
    int count = (int)tempcount;
    

    if (count == 0)
    {
        imageViewOne.image = [UIImage imageNamed:@"Vollie-icon"];
        imageViewTwo.image = [UIImage imageNamed:@"Vollie-icon"];
    }
    else if (count == 1)
    {
        PFObject *tempPhoto = vollieCardData.photosArray[0];
        PFFile *thumbnail = [tempPhoto objectForKey:@"thumbnail"];
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                imageViewOne.image = [UIImage imageWithData:data];
                imageViewTwo.image = [UIImage imageNamed:@"Vollie-icon"];
            }
        }];
    }
    else
    {
        PFObject *firstPhoto = vollieCardData.photosArray[count-2];
        PFFile *firstThumbnailData = [firstPhoto objectForKey:@"thumbnail"];
        [firstThumbnailData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                imageViewOne.image = [UIImage imageWithData:data];
            }
        }];
        PFObject *secondPhoto = vollieCardData.photosArray[count-1];
        PFFile *secondPhotoFile = [secondPhoto objectForKey:@"thumbnail"];
        [secondPhotoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 imageViewTwo.image = [UIImage imageWithData:data];
             }
         }];
//        pfo
    }
}

@end
