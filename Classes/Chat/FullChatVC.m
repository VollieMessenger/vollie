//
//  FullChatVC.m
//  Volley
//
//  Created by Kyle on 7/20/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "FullChatVC.h"
#import "OnePicCell.h"
#import "TwoPicCell.h"
#import "ThreePicCell.h"
#import "FourPicCell.h"
#import "FivePicCell.h"
#import "KLCPopup.h"
#import "NewJSQTestVCViewController.h"

@interface FullChatVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FullChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];

}

-(id)initWithCard:(VollieCardData *)card
{
    self = [super init];
    if (self)
    {
//        self.senderID = [PFUser currentUser].objectId;
//        self.senderDisplayName = [PFUser currentUser][PF_USER_FULLNAME];
//        self.setId = setId;
//        self.setIDforCardCheck = setId;
//        self.messages = [NSMutableArray arrayWithArray:messages];
        self.card = card;
    }
    return self;
}

-(void)fillUIView:(UIView*)view withCardVC:(NewJSQTestVCViewController *)vc
{
    vc.view.frame = view.bounds;
    //        cell.viewForChatVC.layer.cornerRadius = 10;
    //    [self addChildViewController:vc];
    [view addSubview:vc.view];
    [vc updateViewConstraints];
    [vc didMoveToParentViewController:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoPicCell" bundle:0] forCellReuseIdentifier:@"TwoPicCell"];
    TwoPicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoPicCell"];
    [cell fillPicsWithVollieCardData:self.card];
    [cell formatCell];
    [self fillUIView:cell.viewForChatVC withCardVC:self.card.viewController];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

@end
