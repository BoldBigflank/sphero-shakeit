//
//  AppDelegate.h
//  shakeit
//
//  Created by Alex Swan on 3/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
    
	CCDirectorIOS	*director_;							// weak ref
    
    bool robotOnline_;
    int packetCounter;
    
    NSMutableArray *yawArray;
    NSMutableArray *accelArray;
    int shakingTicks;
    int tossingTicks;
    bool isFlipped;
    bool isSpun;
    bool isShaking;
    bool isTossing;
    float prevYaw;
    float cumulativeYaw;
}

-(void)setupRobotConnection;
-(void)handleRobotOnline;
-(void)sendLevelCommand;
-(void) setSpheroLightWithRed:(float)red green:(float)green blue:(float)blue;

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (readonly) bool robotOnline;

@end
