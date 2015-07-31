//
//  SelectRoomVC.h
//  Volley
//
//  Created by Kyle on 6/24/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseVolliePackage.h"

@interface SelectRoomVC : UIViewController

@property NSMutableArray *photosToSend;
@property NSString *textToSend;
@property ParseVolliePackage *package;

@end
