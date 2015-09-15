//
//  Highlight.h
//  Volley
//
//  Created by Kyle Bendelow on 8/25/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Set.h"

@interface HighlightData : NSObject

@property int howManyWeeksAgo;
@property NSNumber *weeksNumberToSortWith;
@property NSMutableArray *sets;
@property NSArray *sortedSets;
@property NSMutableArray *topPics;

-(instancetype)initWithPFObject:(PFObject *)object andAmountOfWeeks:(int)weeks andUserChatroom:(PFObject *)chatroom;


-(void)modifyHighLightWithSet:(PFObject *)set andUserChatroom:(PFObject *)chatroom;

@end
