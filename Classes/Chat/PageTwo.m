//
//  PageTwo.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageTwo.h"

@interface PageTwo ()

@end

@implementation PageTwo

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)onBackButtonTapped:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:1];
}

- (IBAction)onNextButtonTapped:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 2, 0) animated:1];
}

@end
