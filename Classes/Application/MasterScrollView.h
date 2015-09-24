//
//  MasterScrollView.h
//  Volley
//
//  Created by benjaminhallock@gmail.com on 1/28/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NavigationController.h"

@protocol scrollDelegate <NSObject>

-(void)cameraOnOff:(BOOL)toggle;

@end

@interface MasterScrollView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

-(id) init;

#warning TURN INTO NOTIFICATION OR MOVE TO APP DELEGATE

-(void)openView:(UIViewController *)view2;

- (BOOL) checkIfCurrentChatIsEqualToRoom:(NSString *)roomId didComeFromBackground:(BOOL)isBack;

@property BOOL didJustFinishSendingVollie;
@property (nonatomic) id<scrollDelegate>secondaryDelegate;

@end
