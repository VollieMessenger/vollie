//
//  NewVollieVC.h
//  Volley
//
//  Created by Kyle on 6/19/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterScrollView.h"

@protocol NewVollieDelegate <NSObject>
-(void) newVollieDismissed:(NSString *)textForCam;
@end


@interface NewVollieVC : UIViewController

@property (nonatomic, assign) id<NewVollieDelegate> textDelegate;


@property NSString *textFromLastVC;
@property NSMutableArray *photosArray;
@property MasterScrollView *scrollView;
@property BOOL *comingFromCamera;

@end
