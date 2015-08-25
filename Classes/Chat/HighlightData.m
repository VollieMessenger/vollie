//
//  Highlight.m
//  Volley
//
//  Created by Kyle Bendelow on 8/25/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "HighlightData.h"

@implementation HighlightData

-(instancetype)initWithPFObject:(PFObject *)set
{
    self = [super self];
    if(self)
    {
        [self.sets addObject:set];
    }
    return self;
}

-(void)modifyHighLightWithSet:(PFObject *)set
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfResponses" ascending:YES];
    NSArray *sortedSets = [self.sets sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.sortedSets = sortedSets;
}

@end
