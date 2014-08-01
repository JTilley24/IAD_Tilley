//
//  SettingsScene.m
//  Wizards Strike
//  MGD Term 1406
//  Created by Justin Tilley on 7/21/14.
//  Copyright 2014 Justin Tilley. All rights reserved.
//

#import "SettingsScene.h"
#import "CreditsScene.h"
#import "InstructScene.h"
#import "AchieveScene.h"

#define kSimpleTableViewRowHeight 24
#define kSimpleTableViewInset 50

@implementation SettingsScene
{
    CCSpriteBatchNode *spriteSheet;
    CCSpriteBatchNode *settingsSprite;
    float fontSize;
    NSString *backImage;
    CCButton * leaderboardButton;
    NSString *leaderboardString;
    CCTableView *leaderboardTable;
    CCTextField *userText;
    CCTextField *passText;
    CCLabelTTF *loginInfoLabel;
    CCSlider * regionSlider;
    NSArray *regionArray;
    CCLabelTTF *regionLabel;
    CCSlider *sortSlider;
    NSArray *sortArray;
    CCLabelTTF *sortLabel;
    NSString *difficultyString;
    NSArray *localArray;
    NSArray *onlineArray;
    NSArray *currentScores;
}
+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    SettingsScene *settingsLayer = [SettingsScene node];
    [scene addChild: settingsLayer];
    return scene;
}



-(id) init
{
    if(self = [super init]){
        NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
        if(device == CCDeviceiPad){
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet@2x.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet@2x.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet@2x.plist"];
            fontSize = 25.0f;
            backImage = @"back@2x.png";
        }else{
            spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sprite_sheet.png"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprite_sheet.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"settings_sheet.plist"];
            fontSize = 11.0f;
            backImage = @"back.png";
        }
        
        //Set Defaults
        regionArray = @[@"AF",@"AN",@"AS",@"EU",@"NA",@"OC",@"SA"];
        sortArray = @[@"ALL",@"AF",@"AN",@"AS",@"EU",@"NA",@"OC",@"SA"];
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
        background.opacity = 1.0f;
        [self addChild:background];
        
        //Add Settings Background
        CCSprite *settingBG = [CCSprite node];
        [settingBG setTextureRect:CGRectMake(self.contentSize.width/2, self.contentSize.height/2, self.contentSize.width * 0.90f, self.contentSize.height * 0.95f)];
        settingBG.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [settingBG setColor:[CCColor blackColor]];
        [settingBG setOpacity:0.55f];
        [self addChild:settingBG];
        
        //Add Quit Button
        CCButton *backButton = [CCButton buttonWithTitle:@"Back" spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"button-bg.png"]];
        backButton.label.fontSize = fontSize;
        backButton.preferredSize = CGSizeMake(backButton.contentSize.width *1.25, backButton.contentSize.height);
        backButton.positionType = CCPositionTypeNormalized;
        backButton.position = ccp(0.50f, 0.10f);
        [backButton setTarget:self selector:@selector(onBackClicked:)];
        [self addChild:backButton];
        
        //Add label for Login Title
        CCLabelTTF *loginLabel = [CCLabelTTF labelWithString:@"Login" fontName:@"Verdana-Bold" fontSize:fontSize * 1.5];
        loginLabel.positionType = CCPositionTypeNormalized;
        loginLabel.position = ccp(0.25f, 0.95f);
        [self addChild:loginLabel];
        
        //Add Label for Username Text
        CCLabelTTF *userLabel = [CCLabelTTF labelWithString:@"Username:" fontName:@"Verdana-Bold" fontSize:fontSize];
        userLabel.positionType = CCPositionTypeNormalized;
        userLabel.position = ccp(0.15f, 0.90f);
        [self addChild:userLabel];
        
        //Add Label for Password Text
        CCLabelTTF *passLabel = [CCLabelTTF labelWithString:@"Password:" fontName:@"Verdana-Bold" fontSize:fontSize];
        passLabel.positionType = CCPositionTypeNormalized;
        passLabel.position = ccp(0.15f, 0.72f);
        [self addChild:passLabel];
        
        //Add Username TextField
        userText = [CCTextField textFieldWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"textfield-bg.png"]];
        userText.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        userText.fontSize = fontSize;
        userText.contentSize = CGSizeMake(300, 75);
        userText.preferredSize = CGSizeMake(300, 75);
        userText.positionType = CCPositionTypeNormalized;
        userText.position = ccp(0.10f, 0.78f);
        [self addChild:userText];
        
        //Add Password Textfield
        passText = [CCTextField textFieldWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"textfield-bg.png"]];
        passText.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [passText.textField setSecureTextEntry:YES];
        passText.fontSize = fontSize;
        passText.contentSize = CGSizeMake(300, 75);
        passText.preferredSize = CGSizeMake(300, 75);
        passText.positionType = CCPositionTypeNormalized;
        passText.position = ccp(0.10f, 0.60f);
        [self addChild:passText];
        
        //Add Label for Info of Login Status
        loginInfoLabel = [CCLabelTTF labelWithString:@"You are not Logged in." fontName:@"Verdana-Bold" fontSize:fontSize * 0.85f];
        loginInfoLabel.positionType = CCPositionTypeNormalized;
        loginInfoLabel.position = ccp(0.25f, 0.55f);
        [self addChild:loginInfoLabel];
        
        if([PFUser currentUser] != nil){
            [loginInfoLabel setString:[NSString stringWithFormat: @"%@ is logged in.", [[PFUser currentUser] username]]];
            userText.string = [[PFUser currentUser] username];
        }
        
        //Add Login Button
        CCButton *loginButton = [CCButton buttonWithTitle:@" Login "  spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        loginButton.label.fontSize = fontSize;
        loginButton.preferredSize = CGSizeMake(loginButton.contentSize.width * 1.25, loginButton.contentSize.height);
        loginButton.positionType = CCPositionTypeNormalized;
        loginButton.position = ccp(0.18f, 0.45f);
        [loginButton setTarget:self selector:@selector(onLoginClicked:)];
        [self addChild:loginButton];
        
        //Add Signup Button
        CCButton *signupButton = [CCButton buttonWithTitle:@" SignUp " spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        signupButton.label.fontSize = fontSize;
        signupButton.preferredSize = CGSizeMake(signupButton.contentSize.width * 1.25, signupButton.contentSize.height);
        signupButton.positionType = CCPositionTypeNormalized;
        signupButton.position = ccp(0.30f, 0.45f);
        [signupButton setTarget:self selector:@selector(onSignupClicked:)];
        [self addChild:signupButton];
        
        //Add label for Region Slider
        regionLabel = [CCLabelTTF labelWithString:@"Region: NA" fontName:@"Verdana-Bold" fontSize:fontSize * 1.5];
        regionLabel.positionType = CCPositionTypeNormalized;
        regionLabel.position = ccp(0.25f, 0.35f);
        [self addChild:regionLabel];
        
        //Slider Images
        CCSpriteFrame* slBackground = [CCSpriteFrame frameWithImageNamed:@"slider-background.png"];
        CCSpriteFrame* slBackgroundHilite = [CCSpriteFrame frameWithImageNamed:@"slider-background-hilite.png"];
        CCSpriteFrame* slHandle = [CCSpriteFrame frameWithImageNamed:@"slider-handle.png"];
        
        //Add Slider for Region
        regionSlider = [[CCSlider alloc] initWithBackground:slBackground andHandleImage:slHandle];
        [regionSlider setBackgroundSpriteFrame:slBackgroundHilite forState:CCControlStateHighlighted];
        regionSlider.positionType = CCPositionTypeNormalized;
        regionSlider.position = ccp(0.25f, 0.25f);
        regionSlider.anchorPoint = ccp(0.5f, 0.5f);
        regionSlider.preferredSize = CGSizeMake(regionLabel.contentSize.width, regionLabel.contentSize.height);
        regionSlider.continuous = YES;
        [regionSlider setTarget:self selector:@selector(regionSliderCallback:)];
        [self addChild:regionSlider];
        [regionSlider setSliderValue:0.66f];
        
        //Add Credits Button
        CCButton *creditsButton = [CCButton buttonWithTitle:@" Credits " spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        creditsButton.label.fontSize = fontSize;
        creditsButton.preferredSize = CGSizeMake(creditsButton.contentSize.width * 1.25, creditsButton.contentSize.height);
        creditsButton.positionType = CCPositionTypeNormalized;
        creditsButton.position = ccp(0.30f, 0.10f);
        [creditsButton setTarget:self selector:@selector(onCreditsClicked:)];
        [self addChild:creditsButton];
        
        //Add Instructions Button
        CCButton *instructionsButton = [CCButton buttonWithTitle:@" Instructions " spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        instructionsButton.label.fontSize = fontSize;
        instructionsButton.preferredSize = CGSizeMake(instructionsButton.contentSize.width * 1.25, instructionsButton.contentSize.height);
        instructionsButton.positionType = CCPositionTypeNormalized;
        instructionsButton.position = ccp(0.70f, 0.10f);
        [instructionsButton setTarget:self selector:@selector(onInstructClicked:)];
        [self addChild:instructionsButton];
        
        //Add Slider for Leaderbard Sorting
        sortSlider = [[CCSlider alloc] initWithBackground:slBackground andHandleImage:slHandle];
        [sortSlider setBackgroundSpriteFrame:slBackgroundHilite forState:CCControlStateHighlighted];
        sortSlider.positionType = CCPositionTypeNormalized;
        sortSlider.position = ccp(0.70f, 0.80f);
        sortSlider.anchorPoint = ccp(0.5f, 0.5f);
        sortSlider.preferredSize = CGSizeMake(regionSlider.contentSize.width, regionSlider.contentSize.height);
        sortSlider.continuous = YES;
        [sortSlider setTarget:self selector:@selector(sortSliderCallback:)];
        [self addChild:sortSlider];
        
        //Add Label for Sort Slider
        sortLabel = [CCLabelTTF labelWithString:@"Sort: ALL" fontName:@"Verdana-Bold" fontSize:fontSize];
        sortLabel.positionType = CCPositionTypeNormalized;
        sortLabel.position = ccp(0.70f, 0.85f);
        [self addChild:sortLabel];

        //Add button to toggle Leaderboard
        leaderboardButton = [CCButton buttonWithTitle:@"Leaderboard: Local" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-bg.png"]];
        leaderboardButton.label.fontSize = fontSize;
        leaderboardButton.preferredSize = CGSizeMake(leaderboardButton.contentSize.width * 1.25, leaderboardButton.contentSize.height);
        leaderboardButton.positionType = CCPositionTypeNormalized;
        leaderboardButton.position = ccp(0.70f, 0.90f);
        [leaderboardButton setTarget:self selector:@selector(onLeaderButtonClicked:)];
        [self addChild:leaderboardButton];

        // Add a gray background box
        CCNodeColor* colorBg = [CCNodeColor nodeWithColor:[CCColor grayColor]];
        colorBg.contentSizeType = CCSizeTypeMake(CCSizeUnitInsetPoints, CCSizeUnitInsetPoints);
        colorBg.contentSize = CGSizeMake(kSimpleTableViewInset * 2, kSimpleTableViewInset * 2);
        colorBg.userInteractionEnabled = NO;
        colorBg.position = ccp(kSimpleTableViewInset, kSimpleTableViewInset);
        
        //Add Leaderboard TableView
        leaderboardTable = [[CCTableView alloc] init];
        leaderboardTable.contentSizeType = CCSizeTypeNormalized;
        leaderboardTable.contentSize = CGSizeMake(0.30f, 0.50f);
        leaderboardTable.rowHeight = kSimpleTableViewRowHeight;
        leaderboardTable.dataSource = self;
        leaderboardTable.anchorPoint = ccp(0.5f, 0.5f);
        leaderboardTable.positionType = CCPositionTypeNormalized;
        leaderboardTable.position = ccp(0.70f, 0.50f);
        [leaderboardTable setBounces:NO];
        [leaderboardTable setHorizontalScrollEnabled:NO];
        leaderboardTable.block = ^(CCTableView *table){
            [self openAchieveScene:[table selectedRow]];
        };
        [self addChild:leaderboardTable];
    }
    return self;
}

//Change label for Leaderboard Button
-(void) changeLeaderboard
{
    [leaderboardButton.label setString:[[NSString alloc] initWithFormat:@"Leaderboard: %@",leaderboardString]];
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
    int sortInt = round(sortSlider.sliderValue * 6);
    NSString *sortString = [[NSString alloc] initWithFormat:@"%@", [sortArray objectAtIndex:sortInt]];
    
    if(round([sortSlider sliderValue] *6) != 0){
        tempArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Region == %@", sortString]];
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
    int sortInt = round(sortSlider.sliderValue * 6);
    NSString *sortString = [[NSString alloc] initWithFormat:@"%@", [sortArray objectAtIndex:sortInt]];
    
    
    if(round([sortSlider sliderValue] * 6) != 0){
        tempArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Region == %@", sortString]];
    }
    
    return [tempArray count];
}

//Get Local Scores and set Local Array
-(void)getLocalScores
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *difficultyDict = [[defaults objectForKey:difficultyString] mutableCopy];
    localArray = [difficultyDict objectForKey:@"Scores"];
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
        onlineArray = tempArray;
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
-(void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] popScene];
}

//Login User
-(void)onLoginClicked:(id)sender
{
    if([PFUser currentUser] != nil){
        [PFUser logOut];
    }
    NSString *userName = userText.string;
    NSString *password = passText.string;
    [PFUser logInWithUsernameInBackground:userName password:password block:
     ^(PFUser *user, NSError *error) {
         if(user){
             [loginInfoLabel setString:[NSString stringWithFormat:@"You are logged in as %@", userName]];
             for(int i = 0;i < [regionArray count]; i++){
                 NSString *region = [[PFUser currentUser] objectForKey:@"Region"];
                 if([[regionArray objectAtIndex:i] isEqualToString:region]){
                     float regionValue = i/6.0f;
                     [regionSlider setSliderValue:regionValue];
                     NSString *regionString = [[NSString alloc] initWithFormat:@"Region: %@", region];
                     [regionLabel setString:regionString];
                 }
             }
         }else{
             [loginInfoLabel setString:@"Error Logging in."];
         }
     }];
}

//Validate and create New User
-(void)onSignupClicked:(id)sender
{
    if([PFUser currentUser] != nil){
        [PFUser logOut];
    }
    BOOL validate = true;
    PFUser *user = [PFUser user];
    NSString *username = userText.string;
    NSString *password = passText.string;
    NSString *region = [regionArray objectAtIndex: round(regionSlider.sliderValue * 6)];
    if([username isEqualToString:@""]){
        validate = false;
    }
    if([password isEqualToString:@""]){
        validate = false;
    }
    if(validate == true){
        user.username = username;
        user.password = password;
        [user setObject:region forKey:@"Region"];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [loginInfoLabel setString:[NSString stringWithFormat:@"You are logged in as %@", username]];
                [passText.textField setText:@""];
                
            }else{
                NSString *errorText = @"";
                if(error.code == kPFErrorAccountAlreadyLinked){
                    errorText = @"Account Already Linked.";
                }else if (error.code == kPFErrorInvalidEmailAddress){
                    errorText = @"Email is Invalid.";
                }else if(error.code == kPFErrorUsernameTaken){
                    errorText = @"Username Already Taken.";
                }else{
                    errorText = @"Cannot Create Account.";
                }
                [loginInfoLabel setString:errorText];
            }
        }];
    }
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

//Toggle Leaderboard and Button Label
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

//Change Region for User Account
-(void)regionSliderCallback:(id)sender
{
    CCSlider *slider = sender;
    int regionInt = round(slider.sliderValue * 6);
    NSString *regionString = [[NSString alloc] initWithFormat:@"Region: %@", [regionArray objectAtIndex:regionInt]];
    [regionLabel setString:regionString];
}

//Change Region and reload Leaderboard Table
-(void)sortSliderCallback:(id)sender
{
    CCSlider *slider = sender;
    int sortInt = round(slider.sliderValue * 6);
    NSString *sortString = [[NSString alloc] initWithFormat:@"Sort: %@",[sortArray objectAtIndex:sortInt]];
    if(![sortLabel.string isEqualToString:sortString]){
        [sortLabel setString:sortString];
        [leaderboardTable reloadData];
    }
}

@end
