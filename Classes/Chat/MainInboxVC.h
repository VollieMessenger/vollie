//
//  MainInboxVC.h
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterScrollView.h"

@interface MainInboxVC : UIViewController

@property (strong, nonatomic) MasterScrollView *scrollView;
@property NSMutableArray *messages;

@end
