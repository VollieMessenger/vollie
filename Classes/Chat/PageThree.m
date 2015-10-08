//
//  PageThree.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageThree.h"

@interface PageThree ()

@end

@implementation PageThree

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)onBackButtonPressed:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
}

- (IBAction)onNextButtonPressed:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * 3, 0) animated:1];
}
@end
