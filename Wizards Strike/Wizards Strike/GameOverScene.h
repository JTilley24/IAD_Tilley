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

@interface GameOverScene : CCScene {
    
}
@property (nonatomic, strong)NSString *score;
@property (nonatomic, strong)NSString *condition;
+(CCScene *) scene:(NSString *) condition  withScore:(NSString*) score;
-(id) init;
@end
