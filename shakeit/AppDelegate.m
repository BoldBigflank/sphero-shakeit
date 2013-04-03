//
//  AppDelegate.m
//  shakeit
//
//  Created by Alex Swan on 3/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "RobotKit/RobotKit.h"
#import "HelloWorldLayer.h"

#define TOTAL_PACKET_COUNT 200
#define PACKET_THRESHOLD 50

#define SAMPLES_PER_SECOND 20
#define SHAKING_THRESHOLD 4
#define TOSSING_THRESHOLD 3
#define SPINNING_THRESHOLD 135
#define COLOR_COOLDOWN 2

#define FLIP 3
#define SPIN 0
#define SHAKE 1
#define TOSS 2

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_, robotOnline=robotOnline_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // !!!: Use the next line only during beta
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    [TestFlight takeOff:@"004c4e77-dfea-4b2d-8c7c-3484ce0424b4"];
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    robotOnline_ = NO;

	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 

	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    /*When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:0
                                                   packetFrames:0
                                                     sensorMask:RKDataStreamingMaskOff
                                                    packetCount:0];
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
    robotOnline_ = NO;
    HelloWorldLayer*  h = (HelloWorldLayer*) [[[self director] runningScene] getChildByTag:443];
    [h handleRobotOnline:robotOnline_];
    if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    [self setupRobotConnection];

	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:0
                                                   packetFrames:0
                                                     sensorMask:RKDataStreamingMaskOff
                                                    packetCount:0];
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self];
    [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOn];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
    robotOnline_ = NO;
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}

// Sphero functions
-(void)setupRobotConnection {
    NSLog(@"setupRobotConnection");
    robotOnline_ = NO;
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
}

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    if(!robotOnline_) {
        
        [RKSetDataStreamingCommand sendCommandStopStreaming];
        // Start streaming sensor data
        ////First turn off stabilization so the drive mechanism does not move.
        [RKStabilizationCommand sendCommandWithState:RKStabilizationStateOff];
        
        [self sendSetDataStreamingCommand];
        
        ////Register for asynchronise data streaming packets
        [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self selector:@selector(handleAsyncData:)];
    }
    robotOnline_ = YES;
    
    HelloWorldLayer*  h = (HelloWorldLayer*) [[[self director] runningScene] getChildByTag:443];
    [h handleRobotOnline:robotOnline_];
}

-(void)sendSetDataStreamingCommand {
    
    // Requesting the Accelerometer X, Y, and Z filtered (in Gs)
    //            the IMU Angles roll, pitch, and yaw (in degrees)
    //            the Quaternion data q0, q1, q2, and q3 (in 1/10000) of a Q
    RKDataStreamingMask mask =  RKDataStreamingMaskAccelerometerFilteredAll |
    RKDataStreamingMaskIMUAnglesFilteredAll   |
    RKDataStreamingMaskQuaternionAll;
    
    // Note: If your ball has Firmware < 1.20 then these Quaternions
    //       will simply show up as zeros.
    
    // Sphero samples this data at 400 Hz.  The divisor sets the sample
    // rate you want it to store frames of data.  In this case 400Hz/40 = 10Hz
    uint16_t divisor = 1200 / SAMPLES_PER_SECOND;
    
    // Packet frames is the number of frames Sphero will store before it sends
    // an async data packet to the iOS device
    uint16_t packetFrames = 1;
    
    // Count is the number of async data packets Sphero will send you before
    // it stops.  Set a count of 0 for infinite data streaming.
    uint8_t count = 0;
    
    // Send command to Sphero
    [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:divisor
                                                   packetFrames:packetFrames
                                                     sensorMask:mask
                                                    packetCount:count];
    
    
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData
{
    // Need to check which type of async data is received as this method will be called for
    // data streaming packets and sleep notification packets. We are going to ingnore the sleep
    if ([asyncData isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        
//        // Check to see if we need to request more packets
//        packetCounter++;
//        if( packetCounter > (TOTAL_PACKET_COUNT-PACKET_THRESHOLD)) {
//            [self startLocatorStreaming];
//        }
        
        //    // Received sensor data, so display it to the user.
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
        RKAccelerometerData *accelerometerData = sensorsData.accelerometerData;
        RKAttitudeData *attitudeData = sensorsData.attitudeData;
        //    RKQuaternionData *quaternionData = sensorsData.quaternionData;
        //    RKLocatorData *locatorData = sensorsData.locatorData;
        //
        //    NSString *xAcceleration = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.x];
        //    NSString *yAcceleration = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.y];
        //    NSString *zValue = [NSString stringWithFormat:@"%.6f", accelerometerData.acceleration.z];
        //    NSString *pitchValue = [NSString stringWithFormat:@"%.0f", attitudeData.pitch];
        //    NSString *rollValue = [NSString stringWithFormat:@"%.0f", attitudeData.roll];
        //    NSString *yawValue = [NSString stringWithFormat:@"%.0f", attitudeData.yaw];
        //    NSString *q0Value = [NSString stringWithFormat:@"%.6f", quaternionData.quaternions.q0];
        //    NSString *q1Value = [NSString stringWithFormat:@"%.6f", quaternionData.quaternions.q1];
        //    NSString *q2Value = [NSString stringWithFormat:@"%.6f", quaternionData.quaternions.q2];
        //    NSString *q3Value = [NSString stringWithFormat:@"%.6f", quaternionData.quaternions.q3];
        //    NSString *xPosition = [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"];
        //    NSString *yPosition = [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"];
        //    NSString *xVelocityValue = [NSString stringWithFormat:@"%.02f  %@", locatorData.velocity.x, @"cm/s"];
        //    NSString *yVelocityValue = [NSString stringWithFormat:@"%.02f  %@", locatorData.velocity.y, @"cm/s"];
        HelloWorldLayer*  h = (HelloWorldLayer*) [[[self director] runningScene] getChildByTag:443];
        
        float accelVector = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x +
                                  accelerometerData.acceleration.y * accelerometerData.acceleration.y +
                                  accelerometerData.acceleration.z * accelerometerData.acceleration.z );
        
        // Flipping (blue)
        if ( fabsf(attitudeData.pitch) > 90.0  && accelVector > 0.15) {
            if(!isFlipped){
                // Color blue
                [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:1.0]; // Blue
                [h didGuess:FLIP];
                isFlipped = YES;
            }
        }
        else{
            isFlipped = NO;
//            self.actionLabel.text = [NSString stringWithFormat:@"not flipped"];
        }
        
        // Spinning (green)
        // Change this to spinning around the axis that is receiving the most force
        
        if(!prevYaw) prevYaw = 0.0;
        float yawDelta = attitudeData.yaw - prevYaw;
        if(yawDelta > 180.0) yawDelta = yawDelta - 360.0;
        if(yawDelta < -180) yawDelta = yawDelta + 360;
        
        if( cumulativeYaw > 0 && yawDelta > 0){
//            cumulativeYaw += yawDelta;
        } else if (cumulativeYaw < 0 && yawDelta < 0){
//            cumulativeYaw += yawDelta;
        } else {
            cumulativeYaw = 0;
            isSpun = NO;
        }
        
        if(fabsf(attitudeData.pitch) < 60 && fabsf(attitudeData.roll) < 60) {
            cumulativeYaw += yawDelta;
            prevYaw = attitudeData.yaw;

            if (fabsf(cumulativeYaw) > SPINNING_THRESHOLD) {
                if(!isSpun){
                    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0]; // Green
                    [h didGuess:SPIN];
                    isSpun = YES;
                }
            }
        
        }
        //        self.actionLabel.text = [NSString stringWithFormat:@"%.0f", avgYawDelta* SAMPLES_PER_SECOND];
        
        // Shaking (avg accelerometer >> 1) (red)
//        NSLog([NSString stringWithFormat:@"accelVector %.2f", accelVector]);
        if( accelVector > 1.5) {
            shakingTicks--;
            if(shakingTicks < 1){
                if(!isShaking){
                    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0]; // Red
                    [h didGuess:SHAKE];
                    isShaking = YES;
                }
            }
        } else {
            shakingTicks = SHAKING_THRESHOLD;
            isShaking = NO;
        }
        
        if ( accelVector < 0.15 ) {
            tossingTicks--;
            if(tossingTicks < 1){
                if(!isTossing){
                    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:1.0 blue:0.0]; // Yellow
                    [h didGuess:TOSS];
                    isTossing = YES;
                }
            }
        } else {
            tossingTicks = TOSSING_THRESHOLD;
            isTossing = NO;
        }
        
        //NSLog(@"(%f, %f) %f, %f, %f, %f", x, y, r, g, b, a);
        
    }
}

- (void) sendLevelCommand {
    RKSelfLevelCommandOptions options = RKSelfLevelCommandOptionStart;
//    options = RKSelfLevelCommandOptionStart | RKSelfLevelCommandOptionKeepHeading |           RKSelfLevelCommandOptionSleepAfter | RKSelfLevelCommandOptionControlSystemOn;
//    [RKSelfLevelCommand sendCommandWithOptions:0 angleLimit:angleLimit timeout:timeout accuracy:accuracy];
    [RKSelfLevelCommand sendCommandWithOptions:options angleLimit:20 timeout:0.5 accuracy:0.1];
}

@end

