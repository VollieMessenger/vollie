//
//  StreetLegal.m
//  Volley
//
//  Created by Kyle on 7/6/15.
//  Copyright (c) 2015 KZ. All rights reserved.
//

#import "StreetLegal.h"

@implementation StreetLegal

-(void)logSomething
{
    NSLog(@"LOGGIN LIKE A BEAVER");
}

-(void)logSomethingWithAnArray:(NSMutableArray*)array
{
    for (NSString *string in array)
    {
        NSLog(string);
    }
}

@end
