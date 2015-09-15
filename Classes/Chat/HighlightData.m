//
//  Highlight.m
//  Volley
//
//  Created by Kyle Bendelow on 8/25/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "HighlightData.h"

@implementation HighlightData

-(instancetype)initWithPFObject:(PFObject *)set andAmountOfWeeks:(int)weeks andUserChatroom:(PFObject *)chatroom
{
    self = [super self];
    if(self)
    {
        self.sets = [NSMutableArray new];
        self.howManyWeeksAgo = weeks;
        NSLog(@"i was created with %i weeks", self.howManyWeeksAgo);
        self.weeksNumberToSortWith = [NSNumber numberWithInt:weeks];
        Set *customSet = [Set new];
        customSet.set = set;
        customSet.numberOfResponses = [[set objectForKey:@"numberOfResponses"]intValue];
        customSet.userChatroom = chatroom;
        [self.sets addObject:customSet];
//        NSLog(@"created a highlight with %i")
    }
    return self;
}

-(void)modifyHighLightWithSet:(PFObject *)set andUserChatroom:(PFObject *)chatroom
{
    Set *customSet = [Set new];
    customSet.set = set;
    customSet.userChatroom = chatroom;
    customSet.numberOfResponses = [[set objectForKey:@"numberOfResponses"]intValue];
    [self.sets addObject:customSet];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfResponses" ascending:YES];
    NSArray *sortedSets = [self.sets sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSArray* reversedArray = [[sortedSets reverseObjectEnumerator] allObjects];
    self.sortedSets = reversedArray;
    
//    Set *highestSet = reversedArray.firstObject;
//    NSLog(@"the highest response number for week %@ is %i", self.weeksNumberToSortWith, highestSet.numberOfResponses);
    
//    for (Set *setItem in self.sets)
//    {
//        NSLog(@"%i", setItem.numberOfResponses);
//    }
//    NSLog(@"Highlight %i has %li sets in it", self.howManyWeeksAgo, self.sortedSets.count);
}

@end
