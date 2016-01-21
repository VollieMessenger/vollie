//
//  PageOne.m
//  Volley
//
//  Created by Kyle Bendelow on 10/7/15.
//  Copyright © 2015 KZ. All rights reserved.
//

#import "PageOne.h"

@interface PageOne ()
@property (weak, nonatomic) IBOutlet UIImageView *vollieIcon;

@end

@implementation PageOne

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
                                                                        style:UIBarButtonItemStylePlain target:self action:nil];
    favoritesButton.image = [UIImage imageNamed:@"transCam"];
    self.navigationItem.rightBarButtonItem = favoritesButton;
    UIBarButtonItem *cameraButton =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    cameraButton.image = [UIImage imageNamed:@"transCam"];
    self.navigationItem.leftBarButtonItem = cameraButton;
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
