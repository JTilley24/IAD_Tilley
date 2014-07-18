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
    CCButton *creditsButton;
    CCButton *instructButton;
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
        backImage = @"back@2x.png";
    }else{
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
        mainSprites = [CCSpriteBatchNode batchNodeWithFile:@"menu_sprites.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_sprites.plist"];
        backImage = @"back.png";
    }
    [self addChild:spriteSheet];
    [self addChild:mainSprites];
    
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
    startButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"start-button.png"]];
    startButton.position = ccp(self.contentSize.width/2, -startButton.contentSize.height);
    startButton.opacity = 0.0f;
    startButton.cascadeOpacityEnabled = YES;
    [self addChild:startButton];
    
    //Create the Credits Button
    creditsButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"credits-button.png"]];
    creditsButton.position = ccp(self.contentSize.width/2, -creditsButton.contentSize.height);
    creditsButton.opacity = 0.0f;
    creditsButton.cascadeOpacityEnabled = YES;
    [self addChild:creditsButton];
    
    //Create the Instructions Button
    instructButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"instruct-button.png"]];
    instructButton.position = ccp(self.contentSize.width/2, -instructButton.contentSize.height);
    instructButton.opacity = 0.0f;
    instructButton.cascadeOpacityEnabled = YES;
    [self addChild:instructButton];
    
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
    
    //Action to Move and Fade Credits Button
    CCActionCallBlock *mainCreditAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *creditMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/2 - creditsButton.contentSize.height/2)];
        CCActionFadeIn *creditFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [creditsButton runAction:creditMove];
        [creditsButton runAction:creditFade];
    }];
    CCActionDelay *delayCredit = [CCActionDelay actionWithDuration:1.5f];
    CCActionSequence *creditSequence = [CCActionSequence actionWithArray:@[delayCredit, mainCreditAction]];
    
    //Action to Move and Fade Instructions Button
    CCActionCallBlock *mainInstructAction = [CCActionCallBlock actionWithBlock:^{
        CCActionMoveTo *instructMove = [CCActionMoveTo actionWithDuration:1.5f position:CGPointMake(self.contentSize.width/2, self.contentSize.height/2 - instructButton.contentSize.height * 2)];
        CCActionFadeIn *instructFade = [CCActionFadeTo actionWithDuration:2.0f opacity:1.0f];
        [instructButton runAction:instructMove];
        [instructButton runAction:instructFade];
    }];
    CCActionDelay *delayInstruct = [CCActionDelay actionWithDuration:2.0f];
    CCActionSequence *instructSequence = [CCActionSequence actionWithArray:@[delayInstruct, mainInstructAction]];
    
    //Run Actions for UI Elements
    [mainHit runAction:mainHitAction];
    [titleSprite runAction:titleSequence];
    [startButton runAction:startSequence];
    [creditsButton runAction:creditSequence];
    [instructButton runAction:instructSequence];
    
    //Set Targets for Button Methods
    [startButton setTarget:self selector:@selector(onStartClicked:)];
    [creditsButton setTarget:self selector:@selector(onCreditsClicked:)];
    [instructButton setTarget:self selector:@selector(onInstructClicked:)];
  
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
//Go to Credits Scene
-(void)onCreditsClicked:(id)sender
{
    [[CCDirector sharedDirector] pushScene:[CreditsScene scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}
//Go to Instructions Scene
-(void)onInstructClicked:(id)sender
{
    [[CCDirector sharedDirector] pushScene:[InstructScene scene] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
