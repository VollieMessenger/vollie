//
//  PageFour.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageFour.h"

@interface PageFour ()

@end

@implementation PageFour

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)onFinishButtonTapped:(id)sender
{
//    [self dismissViewControllerAnimated:1 completion:0];
    [self.parentVC dismissViewControllerAnimated:YES completion:0];
}


@end
