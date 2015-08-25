//
//  WeekHighlightsVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "WeekHighlightsVC.h"
#import "WeekCell.h"

@interface WeekHighlightsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WeekHighlightsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Highlights";

}

-(void)basicSetUpOFUI
{
    self.tableView.backgroundColor = [UIColor clearColor];
}




#pragma mark "TableView Stuff"

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeekCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    cell.backgroundColor = [UIColor clearColor];
    [cell formatCell];
//    [cell fillPicsWithVollieCardData:card];
    //            [cell fillPicsWithVollieCardData:card];
    //            [cell formatCell];
    //            [self fillUIView:cell.viewForChatVC withCardVC:card.viewController];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}



@end
