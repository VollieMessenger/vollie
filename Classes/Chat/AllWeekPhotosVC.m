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

@interface AllWeekPhotosVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSMutableArray *picturesArray;

@end

@implementation AllWeekPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self basicSetUpAndInit];
    [self setUpUserInterface];
    [self loopForSets];
}

-(void)basicSetUpAndInit
{
    self.picturesArray = [NSMutableArray new];
}

-(void)setUpUserInterface
{
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picturesArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.frame.size.width/3-10), self.collectionView.frame.size.width/3-10);
}

#pragma mark - "Parse Pull"

-(void)loopForSets
{
    for (PFObject *set in self.highlight.sets)
    {
        [self loadPicturesWithSet:set];
    }
}

-(void)loadPicturesWithSet:(PFObject *)set
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"setId" equalTo:set];
    [query whereKey:@"isUploaded" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(!error)
         {
             for (PFObject *messageObject in objects)
             {
                 ParseMedia *object = [[ParseMedia alloc] initWithPFObject:messageObject];
                 [self.picturesArray addObject:object];
//                 NSLog(@"%li pictures in pictures array", self.picturesArray.count);
             }
             [self.collectionView reloadData];
         }
     }];
}

@end
