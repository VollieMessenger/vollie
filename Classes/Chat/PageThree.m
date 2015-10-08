//
//  PageThree.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageThree.h"

@interface PageThree ()
@property (weak, nonatomic) IBOutlet UIImageView *vollieIcon;

@end

@implementation PageThree

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vollieIcon.layer.cornerRadius = 10;
    self.vollieIcon.layer.masksToBounds = YES;
    UIImageView *imageViewVolley = [[UIImageView alloc] init];
    imageViewVolley.image = [UIImage imageNamed:@"volley"];
    self.navigationItem.titleView = imageViewVolley;
    self.navigationItem.titleView.alpha = 1;
    //        self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    self.title = @"";
    //    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                        style:UIBarButtonItemStyleBordered target:self action:nil];
    favoritesButton.image = [UIImage imageNamed:@"transCam"];
    self.navigationItem.rightBarButtonItem = favoritesButton;
    UIBarButtonItem *cameraButton =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    cameraButton.image = [UIImage imageNamed:@"transCam"];
    self.navigationItem.leftBarButtonItem = cameraButton;
    
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
