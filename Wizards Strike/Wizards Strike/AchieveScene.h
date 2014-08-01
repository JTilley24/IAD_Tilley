//
//  AchieveScene.h
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 7/28/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <Parse/Parse.h>

@interface AchieveScene : CCScene <CCTableViewDataSource>{
    
}
@property (nonatomic,strong) NSString *userName;
+(CCScene *)scene:(NSString*)user;
-(id)init;

@end
