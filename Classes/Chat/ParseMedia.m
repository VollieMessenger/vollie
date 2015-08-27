//
//  ParseMedia.m
//  Volley
//
//  Created by Kyle Bendelow on 8/27/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "ParseMedia.h"

@implementation ParseMedia

-(instancetype)initWithPFObject:(PFObject *)object
{
    self = [super self];
    if(self)
    {
        self.set = [object objectForKey:@"setId"];
        self.mediaForCell = [object objectForKey:@"picture"];
        self.thumbNail = [object objectForKey:@"thumbnail"];
    }
    return self;
}

@end
