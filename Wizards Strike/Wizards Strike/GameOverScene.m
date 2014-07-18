//
//  GameOverScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/22/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "GameOverScene.h"
#import "HelloWorldScene.h"
#import "IntroScene.h"

@implementation GameOverScene
{
    CCSpriteBatchNode *spriteSheet;
    float fontSize;
    NSString *backImage;
}
@synthesize score, condition;
+(CCScene *) scene:(NSString *) conditionString  withScore:(NSString*) scoreString
{
    CCScene *scene = [CCScene node];
    GameOverScene *overLayer = [GameOverScene node];
    [overLayer setScore:scoreString];
    [overLayer setCondition:conditionString];
    [overLayer displayConditions];
    [scene addChild: overLayer];
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
        
        //Add Resume Button
        CCButton *restartButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"restart-button.png"]];
        restartButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - restartButton.contentSize.height * 2);
        [restartButton setTarget:self selector:@selector(restartPressed)];
        [self addChild:restartButton];
        
        //Add Quit Button
        CCButton *quitButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"quit-button.png"]];
        quitButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2 - quitButton.contentSize.height * 4);
        [quitButton setTarget:self selector:@selector(quitPressed)];
        [self addChild:quitButton];
        
        
    }
    
    return self;
}
//Display Win or Lose and Score
-(void)displayConditions
{
    CCLabelTTF *conditionLabel = [CCLabelTTF labelWithString:@"" fontName:@"Verdana-Bold" fontSize:fontSize];
    conditionLabel.positionType = CCPositionTypeNormalized;
    conditionLabel.position = ccp(0.5f, 0.85f);
    if([condition isEqualToString:@"win"]){
            NSLog(@"WIN");
        [conditionLabel setString:@"YOU WIN"];
        [conditionLabel setColor:[CCColor blueColor]];
        
    }else if ([condition isEqualToString:@"lose"]){
        NSLog(@"LOSE");
        [conditionLabel setString:@"YOU LOSE"];
        [conditionLabel setColor:[CCColor redColor]];
    }
    [self addChild:conditionLabel];
    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:score fontName:@"Verdana-Bold" fontSize:fontSize - 2.0f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.5f, 0.75f);
    [self addChild:scoreLabel];
}

//Back to Main Menu
-(void)quitPressed
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]];
}

//Return to Game
-(void)restartPressed
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]];
}

@end
