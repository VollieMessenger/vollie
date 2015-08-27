//
//  PhotoCell.h
//  Volley
//
//  Created by Kyle Bendelow on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
//#import "HighlightData.h"

@interface PhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property PFObject *set;
@property PFObject *mediaForCell;

-(void)fillImageViewWithParse:(PFFile *)pictureObject;

@end
