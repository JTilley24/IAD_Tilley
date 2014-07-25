//
//  GameOverScene.h
//  Wizards Strike
//
//  Created by Justin Tilley on 6/22/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <Parse/Parse.h>

@interface GameOverScene : CCScene <CCTableViewDataSource> {
    
}
@property (nonatomic, strong)NSString *score;
@property (nonatomic, strong)NSString *condition;
+(CCScene *) scene:(NSString *) condition  withScore:(NSString*) score;
-(id) init;
@end
