//
//  IntroScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/4/14.
//  Copyright Justin Tilley 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "HelloWorldScene.h"
#import "CCAnimation.h"
#import "CreditsScene.h"
#import "InstructScene.h"
#import "SettingsScene.h"
// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene
{
    CCSpriteBatchNode *spriteSheet;
    CCSpriteBatchNode *mainSprites;
    NSString *backImage;
    CCSprite *titleSprite;
    CCSprite *mainHit;
    CCActionAnimate *mainHitAction;
    CCButton *startButton;
    CCButton *difficultyButton;
    CCButton *settingButton;
    float fontSize;
    NSString *difficultyString;
}
// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    //Check for iPad or iPhone
    NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
    if(device == CCDeviceiPad){
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet@2x.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet@2x.plist"];
        mainSprites = [CCSpriteBatchNode batchNodeWithFile:@"menu_sprites@2x.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_sprites@2x.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet@2x.plist"];
        backImage = @"back@2x.png";
        fontSize = 18.0f;
    }else{
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
        mainSprites = [CCSpriteBatchNode batchNodeWithFile:@"menu_sprites.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_sprites.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet.plist"];
        backImage = @"back.png";
        fontSize = 10.0f;
    }
    [self addChild:spriteSheet];
    [self addChild:mainSprites];
    
    //Set Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"Difficulty"] != nil)
    {
        difficultyString = [defaults objectForKey:@"Difficulty"];
    }else{
      difficultyString = @"Easy";
    }
    
    //Preload Soundfx
    [[OALSimpleAudio sharedInstance] preloadEffect:@"poofSFX.mp3"];
    [[OALSimpleAudio sharedInstance] preloadEffect:@"jingleSFX.mp3"];
    
    // Create Background Image
    CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:background];
    
    //Create Sprite for the title of game
    titleSprite = [CCSprite spriteWithImageNamed:@"title.png"];
    titleSprite.position = ccp(self.contentSize.width/2, -titleSprite.contentSize.height/3);
    titleSprite.opacity = 0.0f;
    [self addChild:titleSprite];
    
    //Create the Cauldron Sprite
    CCSprite *cauldronLG = [CCSprite spriteWithImageNamed:@"Cauldron_lg.png"];
    cauldronLG.position = ccp(self.contentSize.width/2, -cauldronLG.contentSize.height/3);
    [self addChild:cauldronLG];
    
    //Create the Start Button
    startButton = [CCButton buttonWithTitle:@"Start Game" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
    startButton.label.fontSize = fontSize * 2.5;
    startButton.preferredSize = CGSizeMake(startButton.contentSize.width * 1.25, startButton.contentSize.height);
    startButton.position = ccp(self.contentSize.width/2, -startButton.contentSize.height);
    startButton.opacity = 0.0f;
    startButton.cascadeOpacityEnabled = YES;
    [self addChild:startButton];
    
    //Create the Difficulty Button
    difficultyButton = [CCButton buttonWithTitle:[[NSString alloc] initWithFormat:@"Difficulty: %@", difficultyString ] spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
    difficultyButton.label.fontSize = fontSize * 2.5;
    difficultyButton.preferredSize = CGSizeMake(difficultyButton.contentSize.width * 1.25, difficultyButton.contentSize.height);
    difficultyButton.position = ccp(self.contentSize.width/2, -difficultyButton.contentSize.height);
    difficultyButton.opacity = 0.0f;
    difficultyButton.cascadeOpacityEnabled = YES;
    [self addChild:difficultyButton];
    
    //Create the Settings Button
    settingButton = [CCButton buttonWithTitle:@"Settings" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
    settingButton.label.fontSize = fontSize * 2.5;
    settingButton.preferredSize = CGSizeMake(settingButton.contentSize.width * 1.25, settingButton.contentSize.height);
    settingButton.position = ccp(self.contentSize.width/2, -settingButton.contentSize.height);
    settingButton.opacity = 0.0f;
    settingButton.cascadeOpacityEnabled = YES;
    [self addChild:settingButton];
    
    //Create Animation for the Hit in Cauldron
    NSMutableArray *mainHitFrames = [NSMutableArray array];
    for(int i = 1; i < 34; i++){
        NSString *hitIndex = [NSString stringWithFormat:@"main_hit-%d.png", i];
        if(i < 10){
            hitIndex = [NSString stringWithFormat:@"main_hit-0%d.png", i];
        }
        [mainHitFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:hitIndex]];
    }
    mainHit = [CCSprite spriteWithImageNamed:@"main_hit-01.png"];
    mainHit.position = ccp(self.contentSize.width/2, cauldronLG.contentSize.height/3);
    CCAnimation *mainHitAnimate = [CCAnimation animationWithSpriteFrames:mainHitFrames delay:0.1f];
    [mainHitAnimate setRestoreOriginalFrame:YES];
    mainHitAction = [CCActionAnimate actionWithAnimation:mainHitAnimate];
    [self addChild:mainHit];
    
    //Action to Move and Fade Title
    CCActionCallBlock *mainTitleAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *titleMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/1.3)];
        CCActionFadeIn *titleFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [titleSprite runAction:titleMove];
        [titleSprite runAction:titleFade];
        [[OALSimpleAudio sharedInstance] playEffect:@"poofSFX.mp3"];
        [[OALSimpleAudio sharedInstance] playEffect:@"jingleSFX.mp3"];
    }];
    CCActionDelay *delayTitle = [CCActionDelay actionWithDuration:0.5f];
    CCActionSequence *titleSequence = [CCActionSequence actionWithArray:@[delayTitle, mainTitleAction]];
    
    //Action to Move and Fade Start Button
    CCActionCallBlock *mainStartAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *startMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/2 + startButton.contentSize.height)];
        CCActionFadeIn *startFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [startButton runAction:startMove];
        [startButton runAction:startFade];
    }];
    CCActionDelay *delayStart = [CCActionDelay actionWithDuration:1.0f];
    CCActionSequence *startSequence = [CCActionSequence actionWithArray:@[delayStart, mainStartAction]];
    
    //Action to Move and Fade Difficulty Button
    CCActionCallBlock *mainDifficultyAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *difficultyMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/2 - difficultyButton.contentSize.height/2)];
        CCActionFadeIn *difficultyFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [difficultyButton runAction:difficultyMove];
        [difficultyButton runAction:difficultyFade];
    }];
    CCActionDelay *delayDifficulty = [CCActionDelay actionWithDuration:1.5f];
    CCActionSequence *difficultySequence = [CCActionSequence actionWithArray:@[delayDifficulty, mainDifficultyAction]];
    
    //Action to Move and Fade Settings Button
    CCActionCallBlock *mainSettingsAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *settingsMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/2 - settingButton.contentSize.height * 2)];
        CCActionFadeIn *settingsFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [settingButton runAction:settingsMove];
        [settingButton runAction:settingsFade];
    }];
    CCActionDelay *delaySettings = [CCActionDelay actionWithDuration:2.0f];
    CCActionSequence *settingsSequence = [CCActionSequence actionWithArray:@[delaySettings, mainSettingsAction]];
    
    //Run Actions for UI Elements
    [mainHit runAction:mainHitAction];
    [titleSprite runAction:titleSequence];
    [startButton runAction:startSequence];
    [difficultyButton runAction:difficultySequence];
    [settingButton runAction:settingsSequence];
    
    //Set Targets for Button Methods
    [startButton setTarget:self selector:@selector(onStartClicked:)];
    [difficultyButton setTarget:self selector:@selector(onDifficultyClicked:)];
    [settingButton setTarget:self selector:@selector(onSettingsClicked:)];
  
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
//Go to Gameplay i.e HelloWordScene
- (void)onStartClicked:(id)sender
{
    
    [[CCDirector sharedDirector] pushScene:[HelloWorldScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}
//Change Difficulty
-(void)onDifficultyClicked:(id)sender
{
    if([difficultyString isEqualToString:@"Easy"]){
        difficultyString = @"Hard";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Hard" forKey:@"Difficulty"];
        [defaults synchronize];
    }else if ([difficultyString isEqualToString:@"Hard"]){
        difficultyString = @"Easy";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Easy" forKey:@"Difficulty"];
        [defaults synchronize];
    }
    [difficultyButton.label setString:[NSString stringWithFormat:@"Difficulty: %@", difficultyString]];

}
//Go to Settings Scene
-(void)onSettingsClicked:(id)sender
{
    CCScene *settingScene = [SettingsScene scene];
    [[CCDirector sharedDirector] pushScene:settingScene];
}
// -----------------------------------------------------------------------
@end
