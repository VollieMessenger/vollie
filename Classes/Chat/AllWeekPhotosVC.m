//
//  AllWeekPhotosVC.m
//  Volley
//
//  Created by Kyle Bendelow on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "AllWeekPhotosVC.h"
#import "PhotoCell.h"
#import "Set.h"
#import "ParseMedia.h"
#import "CustomChatView.h"
#import "UIColor+JSQMessages.h"
#import "ProgressHUD.h"

@interface AllWeekPhotosVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *picturesArray;
@property NSArray *sortedPicturesArray;
@property int masterSetCounter;
@property int masterSetCounterBefore;

@end

@implementation AllWeekPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self basicSetUpAndInit];
    [self setUpUserInterface];
    [self beginParsePullWithSets];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
}

-(void)basicSetUpAndInit
{
    self.picturesArray = [NSMutableArray new];
    self.sortedPicturesArray = [NSArray new];
}

-(void)setUpUserInterface
{
    NSLog(@"Setting up UI for AllWeekPhotosVC");
    self.collectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark - "CollectionView Stuff"

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    ParseMedia *mediaObject = self.picturesArray[indexPath.item];
    PFFile *thumbnail = mediaObject.thumbNail;
    [cell fillImageViewWithParse:thumbnail];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ParseMedia *mediaObject = self.picturesArray[indexPath.item];
    PFObject *set = mediaObject.set;
    PFObject *chatRoom = mediaObject.userChatroom;
//    NSString *setID = set.objectId;
//    CustomChatView *vc = [[CustomChatView alloc] initWithSetId:setID andColor:[UIColor volleyFamousGreen]];
    CustomChatView *vc = [[CustomChatView alloc] initWithSet:set andUserChatRoom:chatRoom withOrangeBubbles:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picturesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    return CGSizeMake((self.collectionView.frame.size.width/3-10), self.collectionView.frame.size.width/3-10);
    return CGSizeMake((self.collectionView.frame.size.width/3-14), self.collectionView.frame.size.width/3-14);

}

#pragma mark - "Parse Pull"

-(void)beginParsePullWithSets
{
    self.collectionView.hidden = YES;
//    [ProgressHUD show:@"Loading..."];
//    [ProgressHUD show:@"Loading" Interaction:YES];
//    [ProgressHUD show:@"Loading..."];
//    [ProgressHUD showSuccess:@"Loading"];
//    NSLog(@"%li photos this week", self.highlight.sets.count);
    NSString *progressHUDstring = [NSString stringWithFormat:@"Loading %li Vollies...", self.highlight.sets.count];
    [ProgressHUD show:progressHUDstring];
    self.masterSetCounter = (int)self.highlight.sets.count;
    self.masterSetCounterBefore = self.masterSetCounter;
    NSLog(@"%i setcounter", self.masterSetCounter);
    int setCount = (int)self.highlight.sets.count;
    for (int i = 0; i < setCount; i++)
    {
        Set *setObject = self.highlight.sets[i];
        PFObject *set = setObject.set;
        PFObject *chatroom = setObject.userChatroom;
        [self loadPicturesWithSet:set andChatRoom:chatroom];
        if (i == setCount -1)
        {
            NSLog(@"successfully loaded all photos");
        }
    }

}

-(void)delayedShowOfCells
{
//    [ProgressHUD dismiss];
    self.collectionView.hidden = NO;
}

-(void)loadPicturesWithSet:(PFObject *)set andChatRoom:(PFObject*)chatRoom;
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"setId" equalTo:set];
    [query whereKey:@"isUploaded" equalTo:[NSNumber numberWithBool:YES]];
//    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(!error)
         {
             self.masterSetCounter --;
             NSLog(@"%i photos left to download out of %i", self.masterSetCounter, self.masterSetCounterBefore);
//             int
             for (PFObject *messageObject in objects)
             {
                 ParseMedia *object = [[ParseMedia alloc] initWithPFObject:messageObject];
                 object.userChatroom = chatRoom;
                 object.createdAt = messageObject.createdAt;
                 [self.picturesArray addObject:object];
//                 NSLog(@"%@", messageObject.createdAt);
//                 NSSortDescriptor *sortDescriptor;
//                 sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
//                                                              ascending:YES];
//                 NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//                 self.sortedPicturesArray = [self.picturesArray sortedArrayUsingDescriptors:sortDescriptors];
//                 NSLog(@"%li items in sorted array", self.sortedPicturesArray.count);

             }
             if (self.masterSetCounter == 0)
             {
                 //                     [ProgressHUD showSuccess:@"yay"];
                 NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                               ascending:NO];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                self.sortedPicturesArray = [self.picturesArray sortedArrayUsingDescriptors:sortDescriptors];
                 self.picturesArray = self.sortedPicturesArray;
                
                 NSLog(@"showing all pictures now");
                 self.collectionView.hidden = NO;
                 [ProgressHUD dismiss];
            }
             [self.collectionView reloadData];
         }
         else
         {
             NSLog(@"internet problems");
             [ProgressHUD showError:@"Network Too Slow"];
         }
     }];
}

@end
