//
//  TestVC.m
//  Volley
//
//  Created by Kyle Bendelow on 9/29/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "TestVC.h"

@interface TestVC ()

@end

@implementation TestVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
