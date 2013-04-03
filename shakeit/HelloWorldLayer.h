//
//  HelloWorldLayer.h
//  shakeit
//
//  Created by Alex Swan on 3/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "SimpleAudioEngine.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCMenu *menu;
    CCSprite *menuBackground;
    float globalScale;
    int score;
    int high;
    
    int flips;
    int shakes;
    int tosses;
    int spins;
    
    float timer;
    int currentAction;
    BOOL gameInProgress;
    BOOL guessedCorrectly;
    CCSprite *gameWheel;
    CCSprite *cover;
    CCSprite *changeWheel;
    CCSprite *wheel;
    CCParticleSystemQuad *timer1;
    CCParticleSystemQuad *timer2;
    
    CCLabelTTF *currentScore;
    CCLabelTTF *highScore;
    CCMenuItem *sphero;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (void) didGuess:(int)guess;
- (void) handleRobotOnline:(bool)robotOnline;

@end
