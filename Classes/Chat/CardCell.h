//
//  CardCell.h
//  Volley
//
//  Created by Kyle on 6/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITableView *cardTableView;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) IBOutlet UILabel *picLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end
