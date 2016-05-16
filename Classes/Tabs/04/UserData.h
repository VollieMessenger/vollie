//
//  UserData.h
//  Volley
//
//  Created by Kyle Bendelow on 5/16/16.
//  Copyright © 2016 KZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface UserData : NSObject

-(instancetype)initWithPFObject:(PFObject *)object andRoom:(PFObject*)setObject;

-(void)modifyCardWith:(PFObject *)object;

@end
