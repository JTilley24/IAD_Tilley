//
//  SettingsScene.h
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 7/21/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <Parse/Parse.h>

@interface SettingsScene : CCScene <CCTableViewDataSource, CCScrollViewDelegate>{
    
}
+(CCScene *)scene;
-(id)init;

@end
