//
//  CustomCollectionViewCell.h
//  Volley
//
//  Created by benjaminhallock@gmail.com on 12/17/14.
//  Copyright (c) 2014 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>


@interface CustomCollectionViewCell : UICollectionViewCell
@property PFImageView *imageView;
@property NSString *name;
@property UILabel *label;
- (void)format;
@end
