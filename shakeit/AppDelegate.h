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
    
    bool robotOnline;
    int packetCounter;
    
    NSMutableArray *yawArray;
    NSMutableArray *accelArray;
    int shakingTicks;
    int tossingTicks;
}

-(void)setupRobotConnection;
-(void)handleRobotOnline;

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
