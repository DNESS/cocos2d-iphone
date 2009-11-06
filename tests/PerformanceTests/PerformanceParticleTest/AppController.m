//
// cocos2d performance particle test
// Based on the test by Valentin Milea
//

#import "AppController.h"
#import "cocos2d.h"
#import "MainScene.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use Threaded director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeThreadMainLoop];
		
//	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];

	[[CCDirector sharedDirector] attachInWindow:window];
	[CCDirector sharedDirector].displayFPS = YES;
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	
	[window makeKeyAndVisible];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() testWithSubTest:1 particles:kNodesIncrease]];
	
	[[CCDirector sharedDirector] runWithScene:scene];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
