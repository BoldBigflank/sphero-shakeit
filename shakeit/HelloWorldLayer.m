//
//  HelloWorldLayer.m
//  shakeit
//
//  Created by Alex Swan on 3/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

#define FLIP 3
#define SPIN 0
#define SHAKE 1
#define TOSS 2


// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[layer setTag:443];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
		// position the label on the center of the screen
        //		label.position =  ccp( size.width /2 , size.height/2 );

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        // Everything is scaled for a 1024 * 768 device
        globalScale = max(size.width/1024.0, size.height/768.0);
        CCLOG(@"Global Scale %f", globalScale);
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"assets_default.plist"];

        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        [background setScale:2.0*globalScale];
        [self addChild:background];
        
        gameWheel = [CCSprite new];
        wheel = [CCSprite spriteWithFile:@"wheel.png"];
        [gameWheel setScale:globalScale];
        [gameWheel setPosition:ccp(size.width/2, 0)];
        [gameWheel addChild: wheel];
        
        // Ball animations
        CCSprite *flipAnim = [CCSprite new];
        [flipAnim setRotation:45.0];
        [flipAnim setPosition:ccp( wheel.contentSize.width*2/3, wheel.contentSize.height*2/3)];
        CCSprite *flipArrow = [CCSprite spriteWithSpriteFrameName:@"fliparrow.png"];
        [flipArrow setPosition:ccp(20, -5)];
        [flipAnim addChild:flipArrow];
        
        CCSprite *flipBall = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        id c1 = [CCRotateTo actionWithDuration:0.4 angle:180];
        id c2 = [CCDelayTime actionWithDuration:0.4];
        id c3 = [CCRotateTo actionWithDuration:0.1 angle:0];
        [flipBall runAction:[CCRepeatForever actionWithAction:[CCSequence actions:c1, c2, c3, nil]]];
        [flipAnim addChild:flipBall];
        [wheel addChild:flipAnim];

        CCSprite *tossAnim = [CCSprite new];
        [tossAnim setRotation:135.0];
        [tossAnim setPosition:ccp( wheel.contentSize.width*2/3, wheel.contentSize.height*1/3)];
        CCSprite *tossArrow = [CCSprite spriteWithSpriteFrameName:@"tossarrow.png"];
        [tossArrow setPosition:ccp(0,25)];
        [tossAnim addChild:tossArrow];
        CCSprite *tossBall = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        [tossBall runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:1.00 position:ccp(0,0) height:40.0 jumps:1]]];
        [tossAnim addChild:tossBall];
        [wheel addChild:tossAnim];
        
        CCSprite *shakeAnim = [CCSprite new];
        [shakeAnim setRotation:225.0];
        [shakeAnim setPosition:ccp( wheel.contentSize.width*1/3, wheel.contentSize.height*1/3)];
        CCSprite *shakeArrow = [CCSprite spriteWithSpriteFrameName:@"shakearrow.png"];
        [shakeAnim addChild:shakeArrow];
        CCSprite *shakeBall = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        id a1 = [CCMoveBy actionWithDuration:0.12 position:ccp(10, 0)];
        id a2 = [CCMoveBy actionWithDuration:0.24 position:ccp(-20, 0)];
        id a3 = [CCMoveBy actionWithDuration:0.12 position:ccp(10, 0)];
        [shakeBall runAction:[CCRepeatForever actionWithAction:[CCSequence actions:a1, a2, a3, nil]]];
        [shakeAnim addChild:shakeBall];
        [wheel addChild:shakeAnim];
        
        CCSprite *spinAnim = [CCSprite new];
        [spinAnim setRotation:-45.0];
        [spinAnim setPosition:ccp( wheel.contentSize.width*1/3, wheel.contentSize.height*2/3)];
        
        CCSprite *spinArrow = [CCSprite spriteWithSpriteFrameName:@"spinarrow.png"];
        [spinAnim addChild:spinArrow z:1];
        CCSprite *spinBall = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        id b1 = [CCScaleBy actionWithDuration:1.0 scaleX:-1 scaleY:1 ];
        id b1_reverse = [b1 reverse];
        [spinBall runAction:[CCRepeatForever actionWithAction:[CCSequence actions:b1, b1_reverse, nil]]];
        [spinAnim addChild:spinBall];
        [wheel addChild:spinAnim];
        
        changeWheel = [CCSprite spriteWithFile:@"wheel.png"];
        [gameWheel addChild:changeWheel];
        [changeWheel setPosition:ccp(0, -1* [changeWheel contentSize].height/2)];
        
        cover = [CCSprite spriteWithFile:@"cover.png"];
        [gameWheel addChild:cover];
        [wheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:8.0 angle:-360]]];

        currentScore = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:72];
        [currentScore setPosition:ccp(cover.contentSize.width*13/16, cover.contentSize.height*5/8)];
        [cover addChild:currentScore];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        high = [[defaults valueForKey:@"high"] integerValue];
        if(!high) high = 0;
        highScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", high] fontName:@"Arial" fontSize:72];
        [highScore setPosition:ccp(cover.contentSize.width*3/16, cover.contentSize.height*5/8)];
        
        [cover addChild:highScore];
        [self addChild:gameWheel];

        
        // Load sounds
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"shake.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"toss.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"flip.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"spin.wav"];

        [[SimpleAudioEngine sharedEngine] preloadEffect:@"sphero-connected.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"sphero-not-found.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"connect-sphero.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"start.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"begin.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"go.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"newrecord.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"almost.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"itsover.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"nicetry.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"soclose.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"gameover.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pass.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"flip.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"spin.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"toss.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"shake.caf"];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"60.aifc"];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
        
		//
		// Leaderboards and Achievements
		//
		[CCMenuItemFont setFontSize:28];
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

        sphero = [CCMenuItemImage itemWithNormalImage:@"sphero-small.png" selectedImage:@"sphero-small.png" block:^(id sender) {
            [app setupRobotConnection];
			
        }];
        [self handleRobotOnline:[app robotOnline]];
        CCMenuItem *play = [CCMenuItemImage itemWithNormalImage:@"play.png" selectedImage:@"play.png" block:^(id sender) {
            if(![app robotOnline]){
                [[SimpleAudioEngine sharedEngine] playEffect:@"connect-sphero.caf"];
//                return;
            }
            // Start the game
            [menu setIsTouchEnabled:NO]; // Disable the menu
            [menu runAction:[CCMoveBy actionWithDuration:1.0 position:ccp(0, size.height)]];
            [wheel stopAllActions]; // Stop it spinning
            gameInProgress = YES;
            
            score = 0;
            flips = 0;
            spins = 0;
            shakes = 0;
            tosses = 0;
            [currentScore setString:[NSString stringWithFormat:@"%i", score ]];
            [self nextAction];
            
        }];
        
        menuBackground = [CCSprite spriteWithFile:@"window.png"];
        [menuBackground setScale:globalScale];
        [menuBackground setPosition:ccp(0,0)];

        menu = [CCMenu menuWithItems:sphero, play, nil];
        [menu alignItemsHorizontallyWithPadding:[sphero contentSize].width];
        [menu setContentSize:size];
        [menu setScale:globalScale];
        [menu setPosition:ccp( size.width/2,size.height/2)];
        
        [self addChild:menu];
		
//		[self addChild:menuBackground z:2];
		

	}
	return self;
}

- (void) nextAction {
    //[self unscheduleAllSelectors];
    
    // Set the timer
    int bpm = (score / 4)*10 + 80; // Every four points, increase the bpm by 5, starting with 80;
    bpm = min(bpm, 180); // Max 180
    timer = 4.0 * 60 / bpm; // The timer is four beats
    currentAction = arc4random() % 4;
    guessedCorrectly = NO;
    if(score % 4 == 0){ // New bpm
        NSString *musicFile = [NSString stringWithFormat:@"%i.aifc", bpm];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicFile loop:NO];
    }

    [changeWheel stopAllActions];
    [changeWheel setRotation:[wheel rotation]];
    [changeWheel setPosition:[wheel position]];
    id move1 = [CCMoveBy actionWithDuration:0.25 position:ccp(0,-1*[changeWheel contentSize].height/2)];
    id rotate1 = [CCRotateBy actionWithDuration:0.25 angle:30];
    id a1 = [CCSpawn actions:
     rotate1,
     move1, nil];
    [changeWheel runAction:a1];
    
    [wheel setRotation:(45.0 + currentAction * 90)];

    CCSpriteFrame *star = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"star-large.png"];
    [timer1 stopSystem];
    timer1 = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
    [timer1 setTexture:[star texture] withRect:[star rect]];
    [timer1 setDuration:timer];
    [timer1 setPosition:ccp([cover contentSize].width/2 - [cover contentSize].width/2/sqrt(2.0), [cover contentSize].height/2 + [cover contentSize].height/2/sqrt(2.0))];
    [timer1 runAction:[CCMoveTo actionWithDuration:timer position:ccp([cover contentSize].width/2, [cover contentSize].height/2)]];
    [cover addChild:timer1];
    [timer1 autoRemoveOnFinish];

    [timer2 stopSystem];
    timer2 = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
    [timer2 setTexture:[star texture] withRect:[star rect]];
    [timer2 setDuration:timer];
    [timer2 setPosition:ccp([cover contentSize].width/2 + [cover contentSize].width/2/sqrt(2.0), [cover contentSize].height/2 + [cover contentSize].height/2/sqrt(2.0))];
    [timer2 runAction:[CCMoveTo actionWithDuration:timer position:ccp([cover contentSize].width/2, [cover contentSize].height/2)]];
    [cover addChild:timer2];
    [timer2 autoRemoveOnFinish];
    
    
    
    // Announce the action
    switch (currentAction) {
        case FLIP:
            [[SimpleAudioEngine sharedEngine] playEffect:@"flip.caf"];
            break;
        case SHAKE:
            [[SimpleAudioEngine sharedEngine] playEffect:@"shake.caf"];
            break;
        case TOSS:
            [[SimpleAudioEngine sharedEngine] playEffect:@"toss.caf"];
            break;
        case SPIN:
            [[SimpleAudioEngine sharedEngine] playEffect:@"spin.caf"];
            break;
        default:
            break;
    }
    // Start the timer
    CCCallFunc *call = [CCCallFunc actionWithTarget:self selector:@selector(timeout:)];
    CCDelayTime *delay1 = [CCDelayTime actionWithDuration:timer];
    CCSequence *actionToRun = [CCSequence actions:delay1, call, nil];
    [self runAction:actionToRun];
}

- (void) timeout:(float)dt{
    if(guessedCorrectly){
        [self nextAction];
    } else {
        [self endGame];
    }
}

- (void) handleRobotOnline:(bool)robotOnline {
    CCLOG(@"robot Online %i", robotOnline);
    [sphero setPosition:ccp(0,0)];
    if(robotOnline){
        [[SimpleAudioEngine sharedEngine] playEffect:@"sphero-connected.caf"];
        [sphero stopAllActions];
        [TestFlight passCheckpoint:@"sphero connected"];
    } else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"sphero-not-found.caf"];
        [sphero runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:1.21 position:ccp(0,00) height:40.0 jumps:1]]];
    }
}

- (void) didGuess:(int)guess { // Called by the sphero async data
    if(guessedCorrectly) return;
    // Make noises
//    NSLog(@"GUESS %i currentAction %i", guess, currentAction);
    // Play associated sound
    switch (guess) {
        case FLIP:
            [[SimpleAudioEngine sharedEngine] playEffect:@"flip.wav"];
            break;
        case SHAKE:
            [[SimpleAudioEngine sharedEngine] playEffect:@"shake.wav"];
            break;
        case TOSS:
            [[SimpleAudioEngine sharedEngine] playEffect:@"toss.wav"];
            break;
        case SPIN:
            [[SimpleAudioEngine sharedEngine] playEffect:@"spin.wav"];
            break;
        default:
            break;
    }
    
    // Game associated stuff
    if(!gameInProgress) return;
    // If it matches
    if(currentAction == guess){
        CCSpriteFrame *burstImage = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"redast.png"];
        CCParticleSystemQuad *burst = [CCParticleSystemQuad particleWithFile:@"burst.plist"];
        [burst setTexture:[burstImage texture] withRect:[burstImage rect]];
        [burst setPosition:ccp([cover contentSize].width/2, [cover contentSize].height)];
        [cover addChild:burst];
        [burst autoRemoveOnFinish];

        score++;
        if(guess == SHAKE) shakes++;
        else if(guess == TOSS) tosses++;
        else if(guess == FLIP) flips++;
        else if(guess == SPIN) spins++;
        
        [currentScore setString:[NSString stringWithFormat:@"%i", score ]];
        guessedCorrectly = YES;
        AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
        [app sendLevelCommand];
    } else {
        [self endGame];
    }

}

- (void) endGame {
    if(!gameInProgress) return;
    gameInProgress = NO;
    [timer1 stopSystem];
    [timer2 stopSystem];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    CCSpriteFrame *gameOverImage = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bluesquare.png"];
    CCParticleSystemQuad *gameOverParticle = [CCParticleSystemQuad particleWithFile:@"gameover.plist"];
    [gameOverParticle setTexture:[gameOverImage texture] withRect:[gameOverImage rect]];
    [gameOverParticle setPosition:ccp([cover contentSize].width/2, [cover contentSize].height/2)];
    [cover addChild:gameOverParticle];
    [gameOverParticle autoRemoveOnFinish];

    // Stop the wheel
    // Bring up the scoreboard
    
    // Update the preferences
    
    // Put the wheel in rotate mode
    CGSize size = [[CCDirector sharedDirector] winSize];

    [menu setIsTouchEnabled:YES]; // Enable the menu
    [menu runAction:[CCMoveTo actionWithDuration:0.6 position:ccp( size.width/2,size.height/2)]];
    [wheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:8.0 angle:-360]]];
    
    // New High score
    if(score > high){
        [[SimpleAudioEngine sharedEngine] playEffect:@"newrecord.caf"];
        CCLOG(@"High Score");
        high = score;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSString stringWithFormat:@"%i", high] forKey:@"high"];
        [highScore setString:[NSString stringWithFormat:@"%i", high ]];
        [TestFlight passCheckpoint:@"game over - new high score"];

    } else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.caf"];
    }
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
