//
//  MainInboxVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/4/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MainInboxVC.h"
#import "AppConstant.h"

@interface MainInboxVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainInboxVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInterface];




}

-(void)setUpUserInterface
{
    UIImageView *imageViewVolley = [[UIImageView alloc] init];
    imageViewVolley.image = [UIImage imageNamed:@"volley"];
    
    //    NSNumber *number = [self deviceModelName];
    //    number = [NSNumber numberWithFloat:(number.floatValue / 7.0f)];
    
    self.navigationItem.titleView = imageViewVolley;
    self.navigationItem.titleView.alpha = 1;
    //    self.navigationItem.titleView.frame = CGRectMake(0, 0, self.view.frame.size.width, (53 - ([number intValue] * [number intValue])));
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 250, 44);
    
    self.title = @"";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithTitle:@"Fav"
                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(actionFavorties:)];
    favoritesButton.image = [UIImage imageNamed:ASSETS_STAR_ON];
    self.navigationItem.rightBarButtonItem = favoritesButton;
    
    UIBarButtonItem *cameraButton =[[UIBarButtonItem alloc] initWithTitle:@"Cam" style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
    cameraButton.image = [UIImage imageNamed:ASSETS_NEW_CAMERA];
    self.navigationItem.leftBarButtonItem = cameraButton;
}

















#pragma mark "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


@end
