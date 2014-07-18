//
//  InstructScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/25/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "InstructScene.h"
#import "IntroScene.h"

@implementation InstructScene
{
    CCSpriteBatchNode *spriteSheet;
    float fontSize;
    NSString *backImage;
}

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    InstructScene *instructLayer = [InstructScene node];
    [scene addChild: instructLayer];
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
        
        //Add Instructions Label
        CCLabelTTF *instructLabel = [CCLabelTTF labelWithString:@"Instructions" fontName:@"Verdana-Bold" fontSize:fontSize];
        instructLabel.positionType = CCPositionTypeNormalized;
        instructLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        instructLabel.color = [CCColor magentaColor];
        instructLabel.position = ccp(0.5f, 0.90f);
        [self addChild:instructLabel];
        
        //Add Movement Label
        CCLabelTTF *cauldronLabel = [CCLabelTTF labelWithString:@"Touch to move Cauldron" fontName:@"Verdana-Bold" fontSize:fontSize];
        cauldronLabel.positionType = CCPositionTypeNormalized;
        cauldronLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        cauldronLabel.position = ccp(0.5f, 0.75f);
        [self addChild:cauldronLabel];
        
        //Add Gems Label
        CCLabelTTF *gemLabel = [CCLabelTTF labelWithString:@"Catch Gems in the Cauldron" fontName:@"Verdana-Bold" fontSize:fontSize];
        gemLabel.positionType = CCPositionTypeNormalized;
        gemLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        gemLabel.position = ccp(0.5f, 0.35f);
        [self addChild:gemLabel];
        
        //Add Pumpkin Label
        CCLabelTTF *pumpkinLabel = [CCLabelTTF labelWithString:@"Try to avoid the Pumpkins" fontName:@"Verdana-Bold" fontSize:fontSize];
        pumpkinLabel.positionType = CCPositionTypeNormalized;
        pumpkinLabel.horizontalAlignment = kCTLineBreakByCharWrapping;
        pumpkinLabel.position = ccp(0.5f, 0.15f);
        [self addChild:pumpkinLabel];

        //Add Cauldron Sprite
        CCSprite *cauldronSprite = [CCSprite spriteWithImageNamed:@"Cauldron.png"];
        cauldronSprite.position = ccp(self.contentSize.width * 0.5f, self.contentSize.height * 0.55f);
        [self addChild:cauldronSprite];
        
        //Add Gem Sprite
        CCSprite *gemSprite = [CCSprite spriteWithImageNamed:@"Gems01.png"];
        gemSprite.position = ccp(self.contentSize.width * 0.05f, self.contentSize.height * 0.35f);
        [self addChild:gemSprite];
        
        //Add Pumpkin Sprite
        CCSprite *pumpkinSprite = [CCSprite spriteWithImageNamed:@"pumpkin.png"];
        pumpkinSprite.position = ccp(self.contentSize.width * 0.05f, self.contentSize.height * 0.15f);
        [self addChild:pumpkinSprite];
        
    }
    
    return self;
}

//Back to Main Menu
-(void) quitPressed
{
    [[CCDirector sharedDirector] popScene];;
}

@end
