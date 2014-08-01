//
//  AchieveScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 7/28/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "AchieveScene.h"

#define kSimpleTableViewRowHeight 40
#define kSimpleTableViewInset 50

@implementation AchieveScene
{
    CCSpriteBatchNode *spriteSheet;
    CCSpriteBatchNode *settingsSprite;
    float fontSize;
    NSString *backImage;
    NSArray *achieveNameArray;
    PFUser *user;
    CCTableView *achieveTable;
    NSDictionary *achieveDict;
    NSMutableArray *achieveArray;
    NSMutableArray *unlockedArray;
    
}
@synthesize userName;
+(CCScene *) scene:(NSString *) userString
{
    CCScene *scene = [CCScene node];
    AchieveScene *achieveLayer = [AchieveScene node];
    [achieveLayer setUserName:userString];
    [achieveLayer getUser];
    [scene addChild: achieveLayer];
    return  scene;
}

-(id) init
{
    if(self = [super init]){
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
            fontSize = 28.0f;
            backImage = @"back.png";
        }
        
        // Create Background Image
        CCSprite *background = [CCSprite spriteWithImageNamed:backImage];
        background.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        background.opacity = 1.0f;
        [self addChild:background];
        
        //Array of Achievement Names
        achieveNameArray = @[@"Gatherer: Get 5 Gems in-a-row", @"Collector: Get 10 Gems in-a-row", @"Hoarder: Get 15 Gems in-a-row", @"Quick Draw: Get the Orb within 30 seconds", @"Trick-or-Treat: Lose all Lives in 1 minute", @"Apprentice: Reach 10,000 Points", @"Enchanter: Reach 15,000 Points", @"Grand Wizard: Reach 20,000 Points", @"Lucky: Get the Orb in 2 games", @"Skilled: Get the Orb in 4 games", @"Master: Get the Orb in 6 games"];
    
        //Add Achieve Background
        CCSprite *achieveBG = [CCSprite node];
        [achieveBG setTextureRect:CGRectMake(self.contentSize.width/2, self.contentSize.height/2, self.contentSize.width * 0.90f, self.contentSize.height * 0.95f)];
        achieveBG.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [achieveBG setColor:[CCColor blackColor]];
        [achieveBG setOpacity:0.55f];
        [self addChild:achieveBG];
        
        //Add Back Button
        CCButton *backButton = [CCButton buttonWithTitle:@"Back" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        backButton.label.fontSize = fontSize;
        backButton.preferredSize = CGSizeMake(backButton.contentSize.width *1.25, backButton.contentSize.height);
        backButton.positionType = CCPositionTypeNormalized;
        backButton.position = ccp(0.50f, 0.10f);
        [backButton setTarget:self selector:@selector(onBackClicked:)];
        [self addChild:backButton];
        
        //Add Achievement TableView
        achieveTable = [[CCTableView alloc] init];
        achieveTable.contentSizeType = CCSizeTypeNormalized;
        achieveTable.contentSize = CGSizeMake(0.70f, 0.70f);
        achieveTable.rowHeight = kSimpleTableViewRowHeight;
        achieveTable.dataSource = self;
        achieveTable.anchorPoint = ccp(0.5f, 0.5f);
        achieveTable.positionType = CCPositionTypeNormalized;
        achieveTable.position = ccp(0.50f, 0.50f);
        [achieveTable setBounces:NO];
        [achieveTable setHorizontalScrollEnabled:NO];
        [self addChild:achieveTable];

    }
    return self;
}

//Get User passed from Settings Scene
-(void)getUser
{
    if([userName isEqualToString:@""]){
        user = [PFUser currentUser];
        [self showUserLabel];
        [self showDetailLabel];
        [self getAchievements];
    }else{
        PFQuery *query = [PFUser query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for(int i = 0;i < [objects count];i++)
            {
                PFUser *tempUser = (PFUser*)[objects objectAtIndex:i];
                if([tempUser.username isEqualToString:userName]){
                    user = tempUser;
                    [self showUserLabel];
                    [self showDetailLabel];
                    [self getAchievements];
                }
            }
            NSLog(@"%@", [user description]);
        }];
    }
   
}

//Show User Name Label
-(void)showUserLabel{
    CCLabelTTF *userLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@'s Achievments", [user username]]fontName:@"Verdana-Bold" fontSize:fontSize];
    userLabel.positionType = CCPositionTypeNormalized;
    userLabel.position = ccp(0.5f, 0.95f);
    [self addChild:userLabel];
}

//Show Label for Details about Unlocked Achievements
-(void)showDetailLabel
{
    CCLabelTTF *detailLabel = [CCLabelTTF labelWithString:@"*Green Achievements are unlocked." fontName:@"Verdana-Bold" fontSize:fontSize * 0.30f];
    detailLabel.color = [CCColor greenColor];
    detailLabel.positionType = CCPositionTypeNormalized;
    detailLabel.position = ccp(0.5f, 0.25f);
    [self addChild:detailLabel];
}

//Get Achievement Data for User
-(void)getAchievements
{
    achieveDict = user[@"Achievments"];
    unlockedArray = [[NSMutableArray alloc] init];
    //Measurement Achievement
    if([achieveDict valueForKey:@"Gems"] != nil){
        int gemsInt = [[achieveDict valueForKey:@"Gems"] intValue];
        if(gemsInt > 5){
            [unlockedArray addObject:@"0"];
        }
        if(gemsInt > 10){
            [unlockedArray addObject:@"0"];
        }
        if(gemsInt > 15){
            [unlockedArray addObject:@"2"];
        }
    }
    //Completion Achievement
    if([achieveDict valueForKey:@"Quick Draw"] != nil){
        if([[achieveDict valueForKey:@"Quick Draw"] isEqualToString:@"true"]){
            [unlockedArray addObject:@"3"];
        }
    }
    //Negative Achievement
    if([achieveDict valueForKey:@"Trick-or-Treat"] != nil){
        if([[achieveDict valueForKey:@"Trick-or-Treat"] isEqualToString:@"true"]){
            [unlockedArray addObject:@"4"];
        }
    }
    //Measurement Achievement
    if([achieveDict valueForKey:@"Score"] != nil){
        int scoreInt = [[achieveDict valueForKey:@"Score"] intValue];
        if(scoreInt > 20000){
            [unlockedArray addObject:@"7"];
        }else if(scoreInt > 15000){
            [unlockedArray addObject:@"6"];
        }else{
            [unlockedArray addObject:@"5"];
        }
    }
    //Incremental Achievement
    if([achieveDict valueForKey:@"Orbs"] != nil){
        int orbsInt = [[achieveDict valueForKey:@"Orbs"] intValue];
        if(orbsInt > 6){
            [unlockedArray addObject:@"10"];
            [unlockedArray addObject:@"9"];
            [unlockedArray addObject:@"8"];
        }else if (orbsInt > 4){
            [unlockedArray addObject:@"9"];
            [unlockedArray addObject:@"8"];
        }else if (orbsInt > 2){
            [unlockedArray addObject:@"8"];
        }
    }
    //If User has not unlocked any Achievements
    if([achieveArray count] < 1){
        [achieveArray addObject:@"No Unlocked Achievements"];
    }
    [achieveTable reloadData];

}

//TableView of Achievements and Change color for unlocked Achievements
- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell *cell = [CCTableViewCell node];
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    cell.contentSize = CGSizeMake(1, kSimpleTableViewRowHeight);
    
    CCLabelTTF *cellLabel = [CCLabelTTF labelWithString:[achieveNameArray objectAtIndex:index] fontName:@"Verdana-Bold" fontSize:fontSize * 0.45f];
    cellLabel.positionType = CCPositionTypeNormalized;
    cellLabel.position = ccp(0.5f, 0.5f);
    
    CCNodeColor *cellColor = [CCNodeColor nodeWithColor:[CCColor lightGrayColor]];
    cellColor.userInteractionEnabled = NO;
    cellColor.contentSizeType = CCSizeTypeNormalized;
    cellColor.contentSize = CGSizeMake(1, 1);
    
    
    if([unlockedArray containsObject:[NSString stringWithFormat:@"%d", index]]){
        cellColor.color = [CCColor grayColor];
        cellLabel.color = [CCColor greenColor];
    }
    
    CCNodeColor *divider = [CCNodeColor nodeWithColor:[CCColor darkGrayColor]];
    divider.userInteractionEnabled = NO;
    divider.contentSizeType = CCSizeTypeNormalized;
    divider.contentSize = CGSizeMake(1, 0.1);
    
    [cell addChild:cellColor];
    [cell addChild:cellLabel];
    [cell addChild:divider];
    
    return cell;
}

//TableView Rows for Array of Achievements
-(NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return [achieveNameArray count];
}

//Back to Main Menu
-(void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] popScene];
}

@end
