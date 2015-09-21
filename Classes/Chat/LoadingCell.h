//
//  LoadingCell.h
//  Volley
//
//  Created by Kyle Bendelow on 9/18/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
