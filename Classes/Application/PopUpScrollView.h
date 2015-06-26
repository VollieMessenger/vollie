//
//  PopUpScrollView.h
//  Volley
//
//  Created by Kyle on 6/26/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopUpScrollView : UIScrollView

-(instancetype)initWithIndexPathItem:(NSInteger)indexPathItem andPhotosArray:(NSMutableArray*)photosArray;

@end
