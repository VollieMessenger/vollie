//
//  InviteContactsCell.m
//  Volley
//
//  Created by Kyle Bendelow on 8/17/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "InviteContactsCell.h"
#import "UIColor+JSQMessages.h"


@implementation InviteContactsCell

- (void)awakeFromNib
{
//    self.buttonView.backgroundColor = [UIColor blackColor];
    self.buttonView.backgroundColor = [UIColor volleyFamousGreen];
    self.buttonView.layer.cornerRadius = 10;
    self.buttonView.layer.masksToBounds = YES;
    self.buttonView.layer.borderColor = [UIColor colorWithWhite:0.902 alpha:1.000].CGColor;
    self.buttonView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
