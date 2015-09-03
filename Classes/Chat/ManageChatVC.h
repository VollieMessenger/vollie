//
//  ManageChatVC.h
//  Volley
//
//  Created by Kyle on 7/7/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ManageChatDelegate <NSObject>
-(void)titleChange:(NSString *)title;
@end

@interface ManageChatVC : UIViewController

@property PFObject *messageButReallyRoom;
@property PFObject *room;
@property (nonatomic, assign) id<ManageChatDelegate> delegate;

@end
