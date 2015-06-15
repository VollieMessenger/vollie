//
//  CardCell.h
//  Volley
//
//  Created by Kyle on 6/12/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatColView.h"
#import "VollieCardData.h"
//
//@interface AFIndexedCollectionView : UICollectionView
//
//@property (nonatomic, strong) NSIndexPath *indexPath;
//
//@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface CardCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITableView *cardTableView;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) IBOutlet UILabel *picLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *messagesView;
@property (nonatomic, strong) ChatColView *collectionView;
@property VollieCardData *card;


@end
