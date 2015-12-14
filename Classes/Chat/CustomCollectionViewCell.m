//
//  CustomCollectionViewCell.m
//  Volley
//
//  Created by benjaminhallock@gmail.com on 12/17/14.
//  Copyright (c) 2014 KZ. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

@synthesize imageView = _imageView;
@synthesize name = _name;
@synthesize label = _label;

- (void) format
{
//    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 10;
#warning RASTERIZING
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
//    self.imageView.image = [UIImage imageNamed:@"packageimg6"];



}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageView.layer.shadowRadius = 5.0f;
        self.imageView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.imageView.layer.shadowOpacity = 0.5f;
        self.imageView.layer.borderColor = [UIColor redColor].CGColor;
        self.imageView.layer.borderWidth = 1;
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.layer.cornerRadius = 5;
        self.imageView.layer.masksToBounds = 1;

        // Selected background view
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        backgroundView.layer.borderColor = [[UIColor colorWithRed:1 green:1 blue:1 alpha:1]CGColor];
        backgroundView.layer.borderWidth = 0.0f;
        self.selectedBackgroundView = backgroundView;

        // set content view
//        CGRect frame  = CGRectMake(self.bounds.origin.x + 5, self.bounds.origin.y+ 5, self.bounds.size.width, self.bounds.size.height);
//        self.imageView = [[PFImageView alloc] initWithFrame:frame];
//        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageView.clipsToBounds = YES;
//        [self.contentView addSubview:self.imageView];
//
//        CGRect frame2 = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 28, 28);
//        self.label = [[UILabel alloc] initWithFrame:frame2];
//        self.label.layer.cornerRadius = self.bounds.size.width/3.5/2;
//        self.label.layer.masksToBounds = 1;
//        self.label.layer.borderColor = [[UIColor whiteColor]CGColor];
//        self.label.layer.borderWidth = 1;
//        self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.font = [UIFont fontWithName:@"Helvetica Bold" size:12];
//        self.label.textColor = [UIColor whiteColor];
//        [self insertSubview:self.label aboveSubview:self.imageView];
        
        CGRect picFrame  = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        self.imageView = [[PFImageView alloc] initWithFrame:picFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        CGRect initialsFrame = CGRectMake(self.bounds.size.width - 27, self.bounds.origin.y, 28, 28);
        self.label = [[UILabel alloc] initWithFrame:initialsFrame];
//        self.label.layer.cornerRadius = self.bounds.size.width/3.5/2;
        self.label.layer.cornerRadius = self.bounds.size.width/5/2;

        self.label.layer.masksToBounds = 1;
        self.label.layer.borderColor = [[UIColor whiteColor]CGColor];
        self.label.layer.borderWidth = 1;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"Helvetica Bold" size:12];
        self.label.textColor = [UIColor darkGrayColor];
        [self insertSubview:self.label aboveSubview:self.imageView];
//        self.imageView.image = [UIImage imageNamed:@"packageimg6"];

    }
    return self;
}

@end
