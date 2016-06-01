//
//  LoadMoreCell.m
//  Volley
//
//  Created by Kyle Bendelow on 2/28/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import "LoadMoreCell.h"

@implementation LoadMoreCell

- (void)awakeFromNib {
    // Initialization code
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.spinner.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end