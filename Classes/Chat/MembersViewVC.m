//
//  MembersViewVC.m
//  Volley
//
//  Created by Kyle on 7/7/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "MembersViewVC.h"
#import "AppConstant.h"


@interface MembersViewVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *arrayOfNames;

@end

@implementation MembersViewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInterface];
    [self loadMembers];
    self.arrayOfNames = [NSMutableArray new];
}

-(void)loadMembers
{
    PFRelation *users = [self.room relationForKey:PF_CHATROOMS_USERS];
    PFQuery *query = [users query];
//    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:objects];
            for (PFUser *user in array)
            {
                NSString *string = [user valueForKey:PF_USER_FULLNAME];
                if (string.length && string && [[user valueForKey:PF_USER_ISVERIFIED] isEqualToNumber:@YES])
                {
                    [self.arrayOfNames addObject:string];
                }
                else
                {
                    [self.arrayOfNames addObject:[NSString stringWithFormat:@"%@* - pending",[user valueForKey:PF_USER_USERNAME]]];
                }
            }
            [self.tableView reloadData];
        }
        else
        {

        }
    }];
}

-(void)setUpUserInterface
{
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - TableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *nameString = self.arrayOfNames[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = nameString;
    cell.textLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:17.0];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfNames.count;
}


@end
