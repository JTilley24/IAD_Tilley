//
//  HelloWorldScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 6/4/14.
//  Copyright Justin Tilley 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "CCAnimation.h"
#import "PauseScene.h"
#import "GameOverScene.h"
// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_cauldron;
    CCPhysicsNode *_physics;
    CCNode *bottom;
    CCSpriteBatchNode *spriteSheet;
    NSString *backImage;
    BOOL *scheduledAction;
    float fontSize;
    int lives;
    NSMutableArray *livesArray;
    int count;
    int score;
    int point;
    int gravity;
    int multiplier;
    CCLabelTTF *scoreLabel;
    OALSimpleAudio *audio;
    CCSprite *_darkCloud;
    CCActionAnimate *darkCloudAction;
    CCSprite *_blueCloud;
    CCActionAnimate *blueCloudAction;
    CCSprite *wizard;
    CCActionAnimate *wizardStartAction;
    CCActionAnimate *wizardEndAction;
    CCSprite *orb;
    CCActionAnimate *orbAction;
    CCSprite *peg;
    CCActionAnimate *pegAction;
    NSMutableArray *pegsArray;
    int gapSize;
    int pegCount;
    BOOL bonusRound;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    //Check for iPad or iPhone
    NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
    if(device == CCDeviceiPad){
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet@2x.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet@2x.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pegs_sprites@2x.plist"];
        fontSize = 18.0f;
        backImage = @"back@2x.png";
        gapSize = 64;
        gravity = -200;
    }else{
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pegs_sprites.plist"];
        fontSize = 10.0f;
        backImage = @"back.png";
        gapSize = 64 * 0.44f;
        gravity = -100;
    }
    
    [self addChild:spriteSheet];

    // Create Background Image
    CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
    background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:background];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Pause ]" fontName:@"Verdana-Bold" fontSize:fontSize];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onPauseClicked:)];
    [self addChild:backButton];
    
    //Add Score Label
    score = 00;
    scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %d",score] fontName:@"Verdana-Bold" fontSize:fontSize];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.10f, 0.95f);
    [self addChild:scoreLabel];
    
    //Add Lives
    lives = 4;
    livesArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < lives; i++){
        CCSprite *heart = [CCSprite spriteWithImageNamed:@"heart.png"];
        heart.position = ccp((i+2)*heart.contentSize.width, self.contentSize.height - heart.contentSize.height * 3);
        [livesArray addObject:heart];
        [self addChild:heart];
    }
    
    //Create Wizard Sprite and Animation
    wizard = [CCSprite spriteWithImageNamed:@"wizard_01.png"];
    wizard.position = ccp(self.contentSize.width - wizard.contentSize.width/2 , wizard.contentSize.height/2);
    
    NSMutableArray *wizardFrames = [NSMutableArray array];
    
    for(int i = 1; i < 4; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"wizard_0%d.png", i];
        [wizardFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    CCAnimation *wizardStartAnimate = [CCAnimation animationWithSpriteFrames:wizardFrames delay:0.2f];
    CCAnimation *wizardEndAnimate = [CCAnimation animationWithSpriteFrames:[[wizardFrames reverseObjectEnumerator] allObjects] delay:0.1f];
    wizardStartAction = [CCActionAnimate actionWithAnimation:wizardStartAnimate];
    wizardEndAction = [CCActionAnimate actionWithAnimation:wizardEndAnimate];
    [self addChild:wizard];
    
    //Setup Physics
    _physics = [CCPhysicsNode node];
    _physics.gravity = ccp(0, gravity);
    //_physics.debugDraw = YES;
    _physics.collisionDelegate = self;
    [self addChild:_physics];
   
    // Add Cauldron Sprite
    _cauldron = [CCSprite spriteWithImageNamed:@"Cauldron.png"];
    _cauldron.position  = ccp(self.contentSize.width/2, _cauldron.contentSize.height/2);
    _cauldron.physicsBody = [CCPhysicsBody bodyWithRect:CGRectMake(_cauldron.contentSize.width * 0.125, _cauldron.contentSize.height/1.6, _cauldron.contentSize.width * 0.75, _cauldron.contentSize.height/4) cornerRadius:0];
    _cauldron.physicsBody.type = CCPhysicsBodyTypeStatic;
    _cauldron.physicsBody.collisionGroup = @"cauldronGroup";
    _cauldron.physicsBody.collisionType = @"cauldronCollision";
    [_physics addChild:_cauldron];
   
    //Set Cloud Animations
    [self setCloudAnimate];
    
    //Setup Audio Effects
    audio = [OALSimpleAudio sharedInstance];
    [audio preloadEffect:@"poofSFX.mp3"];
    [audio preloadEffect:@"jingleSFX.mp3"];
    [audio preloadEffect:@"pumpkinSFX.mp3"];
    [audio preloadEffect:@"thunder.mp3"];
    
    //Set Bottom, Left, and Right of Scene as a Physics Body for Collision
    CGRect bottomRect = CGRectMake(0, -10, self.contentSize.width, 10);
    bottom = [CCNode node];
    bottom.physicsBody = [CCPhysicsBody bodyWithRect:bottomRect cornerRadius:0];
    bottom.physicsBody.type = CCPhysicsBodyTypeStatic;
    bottom.physicsBody.collisionGroup = @"bottomGroup";
    bottom.physicsBody.collisionType = @"bottomCollision";
    [_physics addChild:bottom];
    
    CGRect leftSideRect = CGRectMake(-10, 0, 10, self.contentSize.width);
    CCNode *leftSide = [CCNode node];
    leftSide.physicsBody = [CCPhysicsBody bodyWithRect:leftSideRect cornerRadius:0];
    leftSide.physicsBody.type = CCPhysicsBodyTypeStatic;
    leftSide.physicsBody.elasticity = 0.4f;
    [_physics addChild:leftSide];
    
    CGRect rightSideRect = CGRectMake(self.contentSize.width + 10, 0, 10, self.contentSize.width);
    CCNode *rightSide = [CCNode node];
    rightSide.physicsBody = [CCPhysicsBody bodyWithRect:rightSideRect cornerRadius:0];
    rightSide.physicsBody.type = CCPhysicsBodyTypeStatic;
    rightSide.physicsBody.elasticity = 0.4f;
    [_physics addChild:rightSide];
    
    //Set Pegs Animation and Bonus Round to false
    [self setPegAnimate];
    bonusRound = false;
    //Set Multiplier and Points
    multiplier = 1;
    point = 75;
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    //Set Timers for Adding Gems and Pumpkins
    if(!scheduledAction){
        [self schedule:@selector(addGems) interval:2.0f];
        [self schedule:@selector(addPumpkin) interval:6.25f];
    }
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Check if Cauldron already moving
    if([_cauldron numberOfRunningActions] > 0){
        [_cauldron stopAllActions];
    }
        
    //Get Touch Location
    CGPoint touchLoc = [touch locationInNode:self];
    CGPoint moveLoc = CGPointMake(touchLoc.x, _cauldron.contentSize.height/2);
    if(touchLoc.x > self.contentSize.width - _cauldron.contentSize.width/2){
        moveLoc = CGPointMake(self.contentSize.width - _cauldron.contentSize.width/2, _cauldron.contentSize.height/2);
    }else if(touchLoc.x < _cauldron.contentSize.width/2){
        moveLoc = CGPointMake(_cauldron.contentSize.width/2, _cauldron.contentSize.height/2);
    }
    
    // Move Cauldron to touch location
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:moveLoc];
    [_cauldron runAction:actionMove];
}

//Add Gems to Scene
-(void) addGems
{
    scheduledAction = true;
    //Set Gem Sprite to Random Gem Image
    int randomGem = ((arc4random() % 5) + 1);
    NSString *gemName = [[NSString alloc] initWithFormat:@"Gems0%d.png", randomGem];
    CCSprite *gem = [CCSprite spriteWithImageNamed:gemName];
    
    //Get Random X-Position
    int minX = gem.contentSize.width/2;
    int maxX = self.contentSize.width - minX;
    int rangeX = maxX - minX;
    int randomX = ((arc4random() % rangeX) + minX);
   
    gem.position = CGPointMake(randomX, self.contentSize.height + gem.contentSize.height/2);
    gem.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:gem.contentSize.width/2.0f andCenter:gem.anchorPointInPoints];
    gem.physicsBody.collisionType = @"gemCollision";
    gem.physicsBody.elasticity = 2.0f;
    [_physics addChild:gem];
    
}

//Add Pumpkins to Scene
-(void) addPumpkin
{
    CCSprite *pumpkin = [CCSprite spriteWithImageNamed:@"pumpkin.png"];
    
    //Get Random X-Position
    int minX = pumpkin.contentSize.width/2;
    int maxX = self.contentSize.width - minX;
    int rangeX = maxX - minX;
    int randomX = ((arc4random() % rangeX) + minX);
    
    pumpkin.position = CGPointMake(randomX, self.contentSize.height + pumpkin.contentSize.height/2);
    pumpkin.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:pumpkin.contentSize.width/2.0f andCenter:pumpkin.anchorPointInPoints];
    pumpkin.physicsBody.collisionType = @"pumpkinCollision";
    pumpkin.physicsBody.elasticity = 2.0f;
    [_physics addChild:pumpkin];
}

//Collision Detection between Gems and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair gemCollision:(CCNode *)gem cauldronCollision:(CCNode *)cauldron
{
    [gem removeFromParent];
    [audio playEffect:@"poofSFX.mp3"];
    [audio playEffect:@"jingleSFX.mp3"];
    [self setMultiplier];
    [self setScore];
    if([_blueCloud numberOfRunningActions] < 1){
        [_blueCloud runAction:blueCloudAction];
    }
    
    return YES;
}

//Collision Detection between Pumpkin and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair pumpkinCollision:(CCNode *)pumpkin cauldronCollision:(CCNode *)cauldron
{
    [pumpkin removeFromParent];
    [audio playEffect:@"pumpkinSFX.mp3"];
    [self endMultiplier];
    [self removeLife];
    if([_darkCloud numberOfRunningActions] < 1){
        [_darkCloud runAction:darkCloudAction];
    }
    return YES;
}

//Collision Detection between Orb and Cauldron
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair orbCollision:(CCNode *)nodeA cauldronCollision:(CCNode *)nodeB
{
    [nodeA removeFromParent];
    [audio playEffect:@"poofSFX.mp3"];
    [audio playEffect:@"jingleSFX.mp3"];
    [self showBonusRound];
    if([_darkCloud numberOfRunningActions] < 1){
        [_darkCloud runAction:darkCloudAction];
    }
    return YES;
}


//Collision Detection between Gems and Bottom of Scene
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair gemCollision:(CCNode *)nodeA bottomCollision:(CCNode *)nodeB
{
    [nodeA removeFromParent];
    if(!bonusRound){
        [self endMultiplier];
    }
    return YES;
}

//Collision Detection between Pumpkins and Bottom of Scene
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair pumpkinCollision:(CCNode *)nodeA bottomCollision:(CCNode *)nodeB
{
    [nodeA removeFromParent];
    return YES;
}

//Collision Detection between Orb and Bottom of Scene
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair orbCollision:(CCNode *)nodeA bottomCollision:(CCNode *)nodeB
{
    [nodeA removeFromParent];
    return YES;
}

//Set Score on Gem to Cauldron Collision
-(void)setScore
{
    int addScore = point * multiplier;
    score = score + addScore;
    NSString *multiplierString = [[NSString alloc] initWithFormat:@"x%d", multiplier];
    if(multiplier == 1){
        multiplierString = @"";
    }
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d %@", score, multiplierString]];
    if (score > 8000) {
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:@"win" withScore:[NSString stringWithFormat:@"Score: %d", score]]];
    }
}

//Set Multiplier
-(void)setMultiplier
{
    count++;
    if(count % 3 == 0){
        multiplier = count/3 + 1;
        //Show Bonus and Wizard Animation
        [self showBonus:[[NSString alloc] initWithFormat:@"x%d", multiplier] textSize:fontSize];
    }else if(count == 4 && !bonusRound){
        //Add Orb for Bonus Round
        [self addOrb];
        [self showBonus:@"Get the Orb" textSize:fontSize * 2];
    }
}

//Remove Multiplier
-(void)endMultiplier
{
    count = 0;
    multiplier = 1;
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %d", score]];
}

//Remove Life and Check if End of Game
-(void)removeLife
{
    lives--;
    [self removeChild:[livesArray lastObject] cleanup:YES];
    [livesArray removeLastObject];
    
    //End Game
    if(lives == 0){
        [[CCDirector sharedDirector] replaceScene:[GameOverScene scene:@"lose" withScore:[NSString stringWithFormat:@"Score: %d", score]]];
    }
}

//Set Cloud Animations
-(void)setCloudAnimate
{
    //Dark Cloud Animation for Pumpkin Collision
    NSMutableArray *darkCloudFrames = [NSMutableArray array];
    for(int i = 1; i<31; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"dark_cloud-%d.png", i];
        if(i < 10){
            sheetIndex = [NSString stringWithFormat:@"dark_cloud-0%d.png", i];
        }
        [darkCloudFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    
    _darkCloud = [CCSprite spriteWithImageNamed:@"dark_cloud-01.png"];
    _darkCloud.position = ccp(_cauldron.contentSize.width/2, _cauldron.contentSize.height - 10);
    CCAnimation *darkCloudAnimate = [CCAnimation animationWithSpriteFrames:darkCloudFrames delay:0.04f];
    [darkCloudAnimate setRestoreOriginalFrame:YES];
    darkCloudAction = [CCActionAnimate actionWithAnimation:darkCloudAnimate];
    [_cauldron addChild:_darkCloud];
   
    //Blue Cloud Animation for Gem Collision
    NSMutableArray *blueCloudFrames = [NSMutableArray array];
    for(int i = 1; i<32; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@" blue_cloud-%d.png", i];
        if(i < 10){
            sheetIndex = [NSString stringWithFormat:@" blue_cloud-0%d.png", i];
        }
        [blueCloudFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    
    _blueCloud = [CCSprite spriteWithImageNamed:@" blue_cloud-01.png"];
    _blueCloud.position = ccp(_cauldron.contentSize.width/2, _cauldron.contentSize.height - 10);
    CCAnimation *blueCloudAnimate = [CCAnimation animationWithSpriteFrames:blueCloudFrames delay:0.04f];
    [blueCloudAnimate setRestoreOriginalFrame:YES];
    blueCloudAction = [CCActionAnimate actionWithAnimation:blueCloudAnimate];
    [_cauldron addChild:_blueCloud];
}
//Show Bonus Label and Wizard Animation
-(void)showBonus: (NSString *) bonus  textSize:(int) size
{
    CCLabelTTF *bonusLabel = [CCLabelTTF labelWithString:bonus fontName:@"Verdana-Bold" fontSize:size];
    bonusLabel.position = ccp(_cauldron.position.x, _cauldron.position.y + _cauldron.contentSize.height);
   
    CCActionCallBlock *bonusStart = [CCActionCallBlock actionWithBlock:^{
        [wizard runAction:wizardStartAction];
    }];
    CCActionCallBlock *bonusSound = [CCActionCallBlock actionWithBlock:^{
        [audio playEffect:@"thunder.mp3"];
    }];
    CCActionFadeIn *bonusFadeIn = [CCActionFadeTo actionWithDuration:0.2 opacity:0.75];
    CCAction *bonusMove = [CCActionMoveTo actionWithDuration:2.0f position:ccp(scoreLabel.contentSize.width, self.contentSize.height - scoreLabel.contentSize.height)];
    CCAction *bonusRemove = [CCActionRemove action];
    CCActionCallBlock *bonusEnd = [CCActionCallBlock actionWithBlock:^{
        [wizard runAction:wizardEndAction];
    }];
    CCActionSequence *bonusSeq = [CCActionSequence actionWithArray:@[bonusStart, bonusSound, bonusFadeIn, bonusMove, bonusRemove, bonusEnd]];
    
    [self addChild:bonusLabel];
    [bonusLabel runAction:bonusSeq];
}

//Set Peg Animation
-(void)setPegAnimate
{
    NSMutableArray *pegFrames = [NSMutableArray array];
    for(int i = 1; i < 8; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"pegs-%d.png", i];
        [pegFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    peg = [CCSprite spriteWithImageNamed:@"pegs-1.png"];
    peg.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:peg.contentSize.width/2.0f andCenter:peg.anchorPointInPoints];
    peg.physicsBody.type = CCPhysicsBodyTypeStatic;
    peg.physicsBody.elasticity = 1.0f;
    peg.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    CCAnimation *pegAnimate = [CCAnimation animationWithSpriteFrames:pegFrames delay:0.125];
    pegAction = [CCActionAnimate actionWithAnimation:pegAnimate];
    [self setPegsArray];
}

//Create an Array of Pegs
-(void)setPegsArray
{
    pegsArray = [NSMutableArray array];
    pegCount = 1;
    int line = 1;
    int pegSpace;
    for(int i = 1; i < 22; i++){
        CCSprite *tempPeg = [CCSprite spriteWithImageNamed:@"pegs-1.png"];
        tempPeg.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:peg.contentSize.width/2.0f andCenter:peg.anchorPointInPoints];
        tempPeg.physicsBody.type = CCPhysicsBodyTypeStatic;
        if(i % 7 == 1){
            pegCount = 1;
            pegSpace = gapSize * 0.45f;
            if(i == 8){
                pegSpace = gapSize * 1.50f;
            }
        }else{
            pegSpace = pegSpace + gapSize * 2.55f;
        }
        tempPeg.position = ccp(pegSpace, self.contentSize.height - gapSize * line * 2);
        [pegsArray addObject:tempPeg];
        pegCount++;
        if(i % 7 == 0){
            line = (i / 7) + 1;
        }
    }
}

//Set Animation for Orb
-(void)addOrb
{
    NSMutableArray *orbFrames = [NSMutableArray array];
    for(int i = 1; i < 5; i++){
        NSString *sheetIndex = [NSString stringWithFormat:@"orbs_0%d.png", i];
        [orbFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sheetIndex]];
    }
    orb = [CCSprite spriteWithImageNamed:@"orbs_01.png"];
    orb.position = CGPointMake(self.contentSize.width/2, self.contentSize.height + orb.contentSize.height/2);
    orb.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:orb.contentSize.width/2.0f andCenter:orb.anchorPointInPoints];
    orb.physicsBody.collisionType = @"orbCollision";
    orb.physicsBody.elasticity = 2.0f;

    CCAnimation *orbAnimate = [CCAnimation animationWithSpriteFrames:orbFrames delay:0.1];
    orbAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:orbAnimate]];
    [_physics addChild:orb];
    [orb runAction:orbAction];
}

//Display Bonus Round and Pegs from PegsArray
-(void)showBonusRound
{
    bonusRound = true;
    
    CCActionCallBlock *roundAction = [CCActionCallBlock actionWithBlock:^{
        [self showBonus:@"Bonus Round" textSize:fontSize * 2];
        [self unscheduleAllSelectors];
    }];
    CCActionCallBlock *addPegsAction = [CCActionCallBlock actionWithBlock:^{
        for(int i = 0; i < pegsArray.count; i++){
            CCSprite *newPeg = [pegsArray objectAtIndex:i];
            [_physics addChild:newPeg];
            [newPeg runAction:[pegAction copy]];
        }
    }];
    CCActionCallBlock *startSchedule = [CCActionCallBlock actionWithBlock:^{
        [self schedule:@selector(addGems) interval:2.0f];
        [self schedule:@selector(addPumpkin) interval:6.25f];
    }];
    CCActionSequence *pegsSeq = [CCActionSequence actionWithArray:@[roundAction, addPegsAction, startSchedule]];
    [self runAction:pegsSeq];
    //Add Points Bonus
    point = point * 2;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
//Display Pause Scene
- (void)onPauseClicked:(id)sender
{
    if(![self paused]){
        CCScene *pauseScene = [PauseScene scene];
        [[CCDirector sharedDirector] pushScene:pauseScene];
    }
}

// -----------------------------------------------------------------------
@end
