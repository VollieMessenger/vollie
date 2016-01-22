//
//  FullWidthCell.h
//  Volley
//
//  Created by Kyle Bendelow on 1/5/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "VollieCardData.h"

@interface FullWidthCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *viewForChatVC;

-(void)formatCell;

@end
