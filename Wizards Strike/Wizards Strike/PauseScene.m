//
//  PauseScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/19/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "PauseScene.h"
#import "IntroScene.h"

@implementation PauseScene
{
    CCSpriteBatchNode *spriteSheet;
    float fontSize;
    NSString *backImage;
}
+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    PauseScene *pauseLayer = [PauseScene node];
    [scene addChild: pauseLayer];
    return scene;
}

-(id) init
{
    if((self = [super init])){
        //Check for iPad or iPhone
        NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
        if(device == CCDeviceiPad){
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet@2x.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet@2x.plist"];
            fontSize = 50.0f;
            backImage = @"back@2x.png";
        }else{
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
            fontSize = 22.0f;
            backImage = @"back.png";
        }
        
        [self addChild:spriteSheet];
        
         // Create Background Image
        CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
        background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        background.opacity = 0.5f;
        [self addChild:background];
        
        //Add Paused Label
        CCLabelTTF *pausedLabel = [CCLabelTTF labelWithString:@"PAUSED" fontName:@"Verdana-Bold" fontSize:fontSize];
        pausedLabel.positionType = CCPositionTypeNormalized;
        pausedLabel.position = ccp(0.5f, 0.85f);
        [self addChild:pausedLabel];
        
        //Add Resume Button
        CCButton *resumeButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"resume-button.png"]];
        resumeButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 + resumeButton.contentSize.height);
        [resumeButton setTarget:self selector:@selector(resumePressed)];
        [self addChild:resumeButton];
        
        //Add Quit Button
        CCButton *quitButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"quit-button.png"]];
        quitButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - quitButton.contentSize.height);
        [quitButton setTarget:self selector:@selector(quitPressed)];
        [self addChild:quitButton];
        
    }
    return self;
}

//Back to Main Menu
-(void) quitPressed
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]];
}

//Return to Game
-(void) resumePressed
{
    [[CCDirector sharedDirector] popScene];
}

@end
