//
//  PageFour.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageFour.h"

@interface PageFour ()
@property (weak, nonatomic) IBOutlet UIImageView *vollieIcon;

@end

@implementation PageFour

- (void)viewDidLoad {
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

- (IBAction)onFinishButtonTapped:(id)sender
{
//    [self dismissViewControllerAnimated:1 completion:0];
    [self.parentVC dismissViewControllerAnimated:YES completion:0];
}

@end
