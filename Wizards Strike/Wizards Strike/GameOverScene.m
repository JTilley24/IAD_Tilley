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
#import "SettingsScene.h"
#import "AchieveScene.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define kSimpleTableViewRowHeight 30

@implementation GameOverScene
{
    CCSpriteBatchNode *spriteSheet;
    float fontSize;
    NSNumber *scoreInt;
    NSString *backImage;
    CCTableView *leaderboardTable;
    CCButton *leaderboardButton;
    NSString *leaderboardString;
    CCSlider *regionSlider;
    CCLabelTTF *regionLabel;
    NSArray *regionArray;
    NSString *difficultyString;
    NSArray *localArray;
    NSArray *onlineArray;
    NSArray *currentScores;
}
@synthesize score;
+(CCScene *) scene:(NSString*) scoreString
{
    CCScene *scene = [CCScene node];
    GameOverScene *overLayer = [GameOverScene node];
    [overLayer setScore:scoreString];
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
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet@2x.plist"];
            fontSize = 50.0f;
            backImage = @"back@2x.png";
        }else{
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet.plist"];
            fontSize = 22.0f;
            backImage = @"back.png";
        }
        
        [self addChild:spriteSheet];
        
        //Set Defaults
        regionArray = @[@"ALL", @"AF",@"AN",@"AS",@"EU",@"NA",@"OC",@"SA"];
        leaderboardString = @"Local";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"Difficulty"] != nil){
            difficultyString = [defaults objectForKey:@"Difficulty"];
        }else{
            difficultyString = @"Easy";
            [defaults setObject:difficultyString forKey:@"Difficulty"];
            [defaults synchronize];
        }
        
        //Get Leaderboard Data
        [self getLocalScores];
        [self getOnlineScores];
        
        // Create Background Image
        CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
        background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        background.opacity = 0.5f;
        [self addChild:background];
        
        //Add Resume Button
        CCButton *restartButton = [CCButton buttonWithTitle:@"Restart" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        restartButton.label.fontSize = fontSize * 0.5f;
        restartButton.preferredSize = CGSizeMake(restartButton.contentSize.width * 1.25, restartButton.contentSize.height);
        restartButton.positionType = CCPositionTypeNormalized;
        restartButton.position = ccp(0.10f, 0.95f);
        [restartButton setTarget:self selector:@selector(restartPressed)];
        [self addChild:restartButton];
        
        //Add Quit Button
        CCButton *quitButton = [CCButton buttonWithTitle:@"Quit" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        quitButton.label.fontSize = fontSize * 0.5f;
        quitButton.preferredSize = CGSizeMake(quitButton.contentSize.width * 1.25, quitButton.contentSize.height);
        quitButton.positionType = CCPositionTypeNormalized;
        quitButton.position = ccp(0.90f, 0.95f);
        [quitButton setTarget:self selector:@selector(quitPressed)];
        [self addChild:quitButton];
        
        //Add Save Highscore Button
        CCButton *saveButton = [CCButton buttonWithTitle:@"Save HighScore" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        saveButton.label.fontSize = fontSize * 0.5f;
        saveButton.preferredSize = CGSizeMake(saveButton.contentSize.width * 1.25, saveButton.contentSize.height);
        saveButton.positionType = CCPositionTypeNormalized;
        saveButton.position = ccp(0.85f, 0.20f);
        [saveButton setTarget:self selector:@selector(saveScorePressed)];
        [self addChild:saveButton];

        //Add Change User Button
        CCButton *userButton = [CCButton buttonWithTitle:@"Change User" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        userButton.label.fontSize = fontSize * 0.5f;
        userButton.preferredSize = CGSizeMake(userButton.contentSize.width * 1.25, userButton.contentSize.height);
        userButton.positionType = CCPositionTypeNormalized;
        userButton.position = ccp(0.85f, 0.10f);
        [userButton setTarget:self selector:@selector(onUserButtonClicked:)];
        [self addChild:userButton];
        
        //Add Twitter Share Button
        CCButton *shareButton = [CCButton buttonWithTitle:@"Tweet" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        shareButton.label.fontSize = fontSize * 0.5f;
        shareButton.preferredSize = CGSizeMake(shareButton.contentSize.width * 1.25, shareButton.contentSize.height);
        shareButton.positionType = CCPositionTypeNormalized;
        shareButton.position = ccp(0.15f, 0.10f);
        [shareButton setTarget:self selector:@selector(onShareButtonClicked:)];
        [self addChild:shareButton];

        //Add Button to Toggle Leaderboard
        leaderboardButton = [CCButton buttonWithTitle:@"Leaderboard: Local" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        leaderboardButton.label.fontSize = fontSize * 0.5f;
        leaderboardButton.preferredSize = CGSizeMake(leaderboardButton.contentSize.width * 1.25, leaderboardButton.contentSize.height);
        leaderboardButton.positionType = CCPositionTypeNormalized;
        leaderboardButton.position = ccp(0.50f, 0.85f);
        [leaderboardButton setTarget:self selector:@selector(onLeaderButtonClicked:)];
        [self addChild:leaderboardButton];

        //Add Leaderboard TableView
        leaderboardTable = [[CCTableView alloc] init];
        leaderboardTable.contentSizeType = CCSizeTypeNormalized;
        leaderboardTable.contentSize = CGSizeMake(0.40f, 0.45f);
        leaderboardTable.rowHeight = kSimpleTableViewRowHeight;
        leaderboardTable.dataSource = self;
        leaderboardTable.anchorPoint = ccp(0.50f, 0.5f);
        leaderboardTable.positionType = CCPositionTypeNormalized;
        leaderboardTable.position = ccp(0.50f, 0.55f);
        [leaderboardTable setBounces:NO];
        [leaderboardTable setHorizontalScrollEnabled:NO];
        leaderboardTable.block = ^(CCTableView *table){
            [self openAchieveScene:[table selectedRow]];
        };
        [self addChild:leaderboardTable];

        //Add label for Region Slider
        regionLabel = [CCLabelTTF labelWithString:@"Region: ALL" fontName:@"Verdana-Bold" fontSize:fontSize * 0.75f];
        regionLabel.positionType = CCPositionTypeNormalized;
        regionLabel.position = ccp(0.50f, 0.25f);
        [self addChild:regionLabel];
        
        //Images for Slider
        CCSpriteFrame* slBackground = [CCSpriteFrame frameWithImageNamed:@"slider-background.png"];
        CCSpriteFrame* slBackgroundHilite = [CCSpriteFrame frameWithImageNamed:@"slider-background-hilite.png"];
        CCSpriteFrame* slHandle = [CCSpriteFrame frameWithImageNamed:@"slider-handle.png"];
        
        //Add Region Slider and set to User's Region
        regionSlider = [[CCSlider alloc] initWithBackground:slBackground andHandleImage:slHandle];
        [regionSlider setBackgroundSpriteFrame:slBackgroundHilite forState:CCControlStateHighlighted];
        regionSlider.positionType = CCPositionTypeNormalized;
        regionSlider.anchorPoint = ccp(0.5f, 0.5f);
        regionSlider.position = ccp(0.50f, 0.15f);
        regionSlider.preferredSize = CGSizeMake(regionLabel.contentSize.width, regionLabel.contentSize.height);
        regionSlider.continuous = YES;
        [regionSlider setTarget:self selector:@selector(regionSliderCallback:)];
        [self addChild:regionSlider];
        if([PFUser currentUser] != nil){
            for(int i = 0; i < [regionArray count]; i++){
                if([[regionArray objectAtIndex:i] isEqualToString:[[PFUser currentUser] objectForKey:@"Region"]]){
                    float regionValue = i/6.0f;
                    [regionSlider setSliderValue:regionValue];
                    NSString *regionString = [[NSString alloc] initWithFormat:@"Region: %@", [[PFUser currentUser] objectForKey:@"Region"]];
                    [regionLabel setString:regionString];
                }
            }
        }else{
            [regionSlider setSliderValue:0];
        }
    }
    
    return self;
}
//Display Score
-(void)displayConditions
{
    NSString *scoreString = score;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterNoStyle];
    scoreInt = [formatter numberFromString:scoreString];
    
    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %@", score]fontName:@"Verdana-Bold" fontSize:fontSize - 2.0f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.5f, 0.95f);
    [self addChild:scoreLabel];
}

//TableView Cells with Name and Score
- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    //Check for Local or Online Leaderboard
    NSArray *tempArray = [[NSArray alloc] init];
    if([leaderboardString isEqualToString:@"Online"]){
        tempArray = onlineArray;
    }else if ([leaderboardString isEqualToString:@"Local"]){
        tempArray = localArray;
    }
    
    //Find Region selection and filter list
    int regionInt = round(regionSlider.sliderValue * 6);
    NSString *regionString = [[NSString alloc] initWithFormat:@"%@", [regionArray objectAtIndex:regionInt]];

    if(round([regionSlider sliderValue] *6) > 0){
        tempArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Region == %@", regionString]];
    }
    
    NSSortDescriptor *sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObject:sortByScore];
    tempArray = [tempArray sortedArrayUsingDescriptors:sortDescriptor];
    
    NSDictionary *tempDict = [tempArray objectAtIndex:index];
    
    currentScores = tempArray;
    
    CCTableViewCell *cell = [CCTableViewCell node];
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    cell.contentSize = CGSizeMake(1, kSimpleTableViewRowHeight);
    
    CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[[tempDict objectForKey:@"Score"] stringValue] fontName:@"Verdana-Bold" fontSize:fontSize * 0.45f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.position = ccp(0.75f, 0.5f);
    
    CCLabelTTF *cellLabel = [CCLabelTTF labelWithString:[tempDict objectForKey:@"User"] fontName:@"Verdana-Bold" fontSize:fontSize * 0.45f];
    cellLabel.positionType = CCPositionTypeNormalized;
    cellLabel.position = ccp(0.25f, 0.5f);
    
    CCNodeColor *cellColor = [CCNodeColor nodeWithColor:[CCColor lightGrayColor]];
    cellColor.userInteractionEnabled = NO;
    cellColor.contentSizeType = CCSizeTypeNormalized;
    cellColor.contentSize = CGSizeMake(1, 1);
    [cell addChild:cellColor];
    [cell addChild:scoreLabel];
    [cell addChild:cellLabel];
    
    return cell;
    
}
//TableView Rows for Array of Scores
- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    //Check for Local or Online leaderboard
    NSArray *tempArray = [[NSArray alloc] init];
    if([leaderboardString isEqualToString:@"Online"]){
        tempArray = onlineArray;
    }else if ([leaderboardString isEqualToString:@"Local"]){
        tempArray = localArray;
    }
    
    //Find Region selection and filter list count
    int regionInt = round(regionSlider.sliderValue * 6);
    NSString *regionString = [[NSString alloc] initWithFormat:@"%@", [regionArray objectAtIndex:regionInt]];
    
    if(round([regionSlider sliderValue] * 6) != 0){
        tempArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Region == %@", regionString]];
    }

    return [tempArray count];
}

//Change Label for Leaderboard Button
-(void) changeLeaderboard
{
    [leaderboardButton.label setString:[[NSString alloc] initWithFormat:@"Leaderboard: %@",leaderboardString]];
}

//Get Local Scores and set Local Array
-(void)getLocalScores
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *difficultyDict = [[defaults objectForKey:difficultyString] mutableCopy];
    localArray = [difficultyDict objectForKey:@"Scores"];
    NSSortDescriptor *sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObject:sortByScore];
    localArray = [localArray sortedArrayUsingDescriptors:sortDescriptor];
    NSLog(@"%@", [localArray description]);
}

//Get Online Scores and set Online Array
-(void)getOnlineScores
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    int regionInt = round(regionSlider.sliderValue * 6);
    PFQuery *scoresQuery = [PFQuery queryWithClassName:difficultyString];
    [scoresQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        for(int i = 0; i< [objects count]; i++){
            PFObject *object = [objects objectAtIndex:i];
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setObject:object[@"User"] forKey:@"User"];
            [tempDict setObject:object[@"Score"] forKey:@"Score"];
            [tempDict setObject:object[@"Region"] forKey:@"Region"];
            [tempArray addObject:tempDict];
        }
        NSSortDescriptor *sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:NO];
        NSArray *sortDescriptor = [NSArray arrayWithObject:sortByScore];
        onlineArray= [tempArray sortedArrayUsingDescriptors:sortDescriptor];
        NSLog(@"%@", [regionArray objectAtIndex:regionInt]);
        NSLog(@"%@", [onlineArray description]);
    } ];
    
}

//Go to Achievements Scene
-(void)openAchieveScene:(int)row
{
    NSDictionary *tempDict = [currentScores objectAtIndex:row];
    NSLog(@"%@", [tempDict objectForKey:@"User"]);
    if(![[tempDict objectForKey:@"User"] isEqualToString:@"Unknown"]){
        [[CCDirector sharedDirector] pushScene:[AchieveScene scene:[tempDict objectForKey:@"User"]]];
    }
    
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

//Save score to Local and Online
-(void) saveScorePressed
{
    PFObject *scoreObject = [PFObject objectWithClassName: difficultyString];
    PFUser *current = [PFUser currentUser];
    if(current != nil){
        scoreObject[@"User"] = current.username;
        scoreObject[@"Score"] = scoreInt;
        scoreObject[@"Region"] = [current objectForKey:@"Region"];
    }else{
        scoreObject[@"User"] = @"Unknown";
        scoreObject[@"Score"] = scoreInt;
        scoreObject[@"Region"] = [NSString stringWithFormat:@"%@", [regionArray objectAtIndex:round(regionSlider.sliderValue * 6)]];
    }
    [scoreObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [leaderboardTable reloadData];
    }];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *difficultyDict = [[defaults objectForKey:difficultyString] mutableCopy];
    if(difficultyDict == nil){
        difficultyDict = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *scoresDict = [[difficultyDict objectForKey:@"Scores"] mutableCopy];
    if(scoresDict == nil){
        scoresDict = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *newScore = [[NSMutableDictionary alloc] init];
    [newScore setObject:scoreObject[@"User"] forKey:@"User"];
    [newScore setObject:scoreInt forKey:@"Score"];
    [newScore setObject:scoreObject[@"Region"] forKey:@"Region"];
    [scoresDict addObject:newScore];
    [difficultyDict setObject:scoresDict forKey:@"Scores"];
    [defaults setObject:difficultyDict forKey:difficultyString];
    [defaults synchronize];
    [self getLocalScores];
    [self getOnlineScores];
    [leaderboardTable reloadData];
}

//Toggle Leaderboard and Button label
-(void)onLeaderButtonClicked:(id)sender
{
    if([leaderboardString isEqualToString:@"Local"])
    {
        leaderboardString = @"Online";
        [self changeLeaderboard];
        [leaderboardTable reloadData];
    }else if ([leaderboardString isEqualToString:@"Online"])
    {
        leaderboardString = @"Local";
        [self changeLeaderboard];
        [leaderboardTable reloadData];
    }
}

//Open Settings Scene
-(void)onUserButtonClicked:(id)sender
{
    CCScene *settingScene = [SettingsScene scene];
    [[CCDirector sharedDirector] pushScene:settingScene];
}

//Open Twitter Compose View
-(void)onShareButtonClicked:(id)sender
{
    SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    if(composer != nil){
        [composer setInitialText:[NSString stringWithFormat:@"New Score of %d in Wizard Strike!", [score intValue]]];
        [[CCDirector sharedDirector] presentViewController:composer animated:YES completion:nil];
    }
}

//Change Region and reload Leaderboard Table
-(void)regionSliderCallback:(id)sender
{
    
    CCSlider *slider = sender;
    int regionInt = round(slider.sliderValue * 6);
    NSString *regionString = [[NSString alloc] initWithFormat:@"Region: %@", [regionArray objectAtIndex:regionInt]];
    if(![regionLabel.string isEqualToString:regionString]){
        [regionLabel setString:regionString];
        [leaderboardTable reloadData];
    }
    
}

@end
