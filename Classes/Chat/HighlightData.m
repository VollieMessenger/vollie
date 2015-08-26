//
//  Highlight.m
//  Volley
//
//  Created by Kyle Bendelow on 8/25/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "HighlightData.h"

@implementation HighlightData

-(instancetype)initWithPFObject:(PFObject *)set andAmountOfWeeks:(int)weeks
{
    self = [super self];
    if(self)
    {
        self.sets = [NSMutableArray new];
        self.howManyWeeksAgo = weeks;
        self.weeksNumberToSortWith = [NSNumber numberWithInt:weeks];
        Set *customSet = [Set new];
        customSet.set = set;
        customSet.numberOfResponses = [[set objectForKey:@"numberOfResponses"]intValue];
        [self.sets addObject:set];
    }
    return self;
}

-(void)modifyHighLightWithSet:(PFObject *)set
{
    Set *customSet = [Set new];
    customSet.set = set;
    customSet.numberOfResponses = [[set objectForKey:@"numberOfResponses"]intValue];
    [self.sets addObject:set];    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfResponses" ascending:YES];
    NSArray *sortedSets = [self.sets sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSArray* reversedArray = [[sortedSets reverseObjectEnumerator] allObjects];
    self.sortedSets = reversedArray;
//    NSLog(@"Highlight %i has %li sets in it", self.howManyWeeksAgo, self.sortedSets.count);
}

@end
