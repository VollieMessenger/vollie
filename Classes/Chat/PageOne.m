//
//  PageOne.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageOne.h"

@interface PageOne ()

@end

@implementation PageOne

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onRightButtonPushed:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
