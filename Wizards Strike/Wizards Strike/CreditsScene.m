//
//  CreditsScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/25/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "CreditsScene.h"
#import "IntroScene.h"

@implementation CreditsScene
{
    CCSpriteBatchNode *spriteSheet;
    float fontSize;
    NSString *backImage;
}

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CreditsScene *creditsLayer = [CreditsScene node];
    [scene addChild: creditsLayer];
    return scene;
}

-(id) init
{
    //Check for iPad or iPhone
    if((self = [super init])){
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
        
        // Create Background Image
        CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
        background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        background.opacity = 0.5f;
        [self addChild:background];

        //Add Quit Button
        CCButton *quitButton = [CCButton buttonWithTitle:@"" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"quit-button.png"]];
        quitButton.position = ccp(self.contentSize.width - quitButton.contentSize.width, self.contentSize.height - quitButton.contentSize.height);
        [quitButton setTarget:self selector:@selector(quitPressed)];
        [self addChild:quitButton];
        
        //Add Credits Label
        CCLabelTTF *creditLabel = [CCLabelTTF labelWithString:@"Credits" fontName:@"Verdana-Bold" fontSize:fontSize];
        creditLabel.positionType = CCPositionTypeNormalized;
        creditLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        creditLabel.color = [CCColor magentaColor];
        creditLabel.position = ccp(0.5f, 0.90f);
        [self addChild:creditLabel];
        
        //Add Developer Label
        CCLabelTTF *devLabel = [CCLabelTTF labelWithString:@"Developer: \n Justin Tilley" fontName:@"Verdana-Bold" fontSize:fontSize];
        devLabel.positionType = CCPositionTypeNormalized;
        devLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        devLabel.position = ccp(0.5f, 0.65f);
        [self addChild:devLabel];

        //Add Audio Label
        CCLabelTTF *audioLabel = [CCLabelTTF labelWithString:@"Audio: \n Courtesy of FreeSound.org" fontName:@"Verdana-Bold" fontSize:fontSize];
        audioLabel.positionType = CCPositionTypeNormalized;
        audioLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        audioLabel.position = ccp(0.5f, 0.45f);
        [self addChild:audioLabel];
        
        //Add Art Label
        CCLabelTTF *artLabel = [CCLabelTTF labelWithString:@"Art: \n Courtesy of OpenGameArt.org" fontName:@"Verdana-Bold" fontSize:fontSize];
        artLabel.positionType = CCPositionTypeNormalized;
        artLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        artLabel.position = ccp(0.5f, 0.25f);
        [self addChild:artLabel];

    }
    
    return self;
}

//Back to Main Menu
-(void) quitPressed
{
    [[CCDirector sharedDirector] popScene];
}

@end
