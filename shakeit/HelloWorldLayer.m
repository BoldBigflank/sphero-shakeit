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

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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

        
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        [background setScale:size.width / [background contentSize].width*2];
        [self addChild:background];
        
        CCSprite *gameWheel = [CCSprite new];
        CCSprite *wheel = [CCSprite spriteWithFile:@"wheel.png"];
        [gameWheel setScale:size.width / [wheel contentSize].width];
        [gameWheel setPosition:ccp(size.width/2, 0)];
        [gameWheel addChild: wheel];
        CCSprite *cover = [CCSprite spriteWithFile:@"cover.png"];
        [gameWheel addChild:cover];
        [wheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:8.0 angle:-360]]];

        [self addChild:gameWheel];


		
		
		
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
        CCMenuItem *sphero = [CCMenuItemImage itemWithNormalImage:@"sphero.png" selectedImage:@"sphero.png" block:^(id sender) {
            AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            [app setupRobotConnection];
			
        }];
        [sphero runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:1.21 position:ccp(0,00) height:40.0 jumps:1]]];
		
		CCMenu *menu = [CCMenu menuWithItems:sphero, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/5, size.height*3/4 + 10)];
		
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
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
