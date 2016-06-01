//
//  EditCardVC.h
//  Volley
//
//  Created by Kyle Bendelow on 2/15/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol EditCardDelegate <NSObject>
-(void)titleChange:(NSString *)title;
@end

@interface EditCardVC : UIViewController
@property NSString *cardTitle;
@property PFObject *set;

@property (nonatomic, assign) id<EditCardDelegate> cardDelegate;

@end