//
// cocos node tests
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "cocosnodeTest.h"

enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
	kTagSprite3 = 3,
};


static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Test2",
			@"Test4",
			@"Test5",
			@"Test6",
			@"StressTest1",
			@"StressTest2",
			@"SchedulerTest1",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


@implementation TestDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
	
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end


@implementation Test2
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	CCSprite *sp3 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp4 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = ccp(100, s.height /2 );
	sp2.position = ccp(380, s.height /2 );
	[self addChild: sp1];
	[self addChild: sp2];
	
	sp3.scale = 0.25f;
	sp4.scale = 0.25f;
	
	[sp1 addChild:sp3];
	[sp2 addChild:sp4];
	
	id a1 = [CCRotateBy actionWithDuration:2 angle:360];
	id a2 = [CCScaleBy actionWithDuration:2 scale:2];
	
	id action1 = [CCRepeatForever actionWithAction:
				  [CCSequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [CCRepeatForever actionWithAction:
				  [CCSequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	sp2.anchorPoint = ccp(0,0);
	
	[sp1 runAction:action1];
	[sp2 runAction:action2];	
}
-(NSString *) title
{
	return @"anchorPoint and children";
}
@end

@implementation Test4
-(id) init
{
	if( !( self=[super init]) )
		return nil;
		
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = ccp(100,160);
	sp2.position = ccp(380,160);
	
	[self addChild:sp1 z:0 tag:2];
	[self addChild:sp2 z:0 tag:3];
	
	[self schedule:@selector(delay2:) interval:2.0f];
	[self schedule:@selector(delay4:) interval:4.0f];
	
	return self;
}

-(void) delay2:(ccTime) dt
{
	id node = [self getChildByTag:2];
	id action1 = [CCRotateBy actionWithDuration:1 angle:360];
	[node runAction:action1];
}

-(void) delay4:(ccTime) dt
{
	[self unschedule:_cmd];
	[self removeChildByTag:3 cleanup:NO];
}


-(NSString *) title
{
	return @"tags";
}
@end

@implementation Test5
-(id) init
{
	if( ( self=[super init]) ) {

		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = ccp(100,160);
		sp2.position = ccp(380,160);

		id rot = [CCRotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever = [CCRepeatForever actionWithAction:
						[CCSequence actions:rot, rot_back, nil]];
		id forever2 = [[forever copy] autorelease];
		[forever setTag:101];
		[forever2 setTag:102];
													  
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[self addChild:sp2 z:0 tag:kTagSprite2];
				
		[sp1 runAction:forever];
		[sp2 runAction:forever2];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CCNode *sp1 = [self getChildByTag:kTagSprite1];
	CCNode *sp2 = [self getChildByTag:kTagSprite2];

	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];

}


-(NSString *) title
{
	return @"remove and cleanup";
}
@end

@implementation Test6
-(id) init
{
	if( ( self=[super init]) ) {
		
		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sp11 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];

		CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCSprite *sp21 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = ccp(100,160);
		sp2.position = ccp(380,160);
		
		
		id rot = [CCRotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever1 = [CCRepeatForever actionWithAction:
					  [CCSequence actions:rot, rot_back, nil]];
		id forever11 = [[forever1 copy] autorelease];

		id forever2 = [[forever1 copy] autorelease];
		id forever21 = [[forever1 copy] autorelease];
		
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[sp1 addChild:sp11];
		[self addChild:sp2 z:0 tag:kTagSprite2];
		[sp2 addChild:sp21];
		
		[sp1 runAction:forever1];
		[sp11 runAction:forever11];
		[sp2 runAction:forever2];
		[sp21 runAction:forever21];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CCNode *sp1 = [self getChildByTag:kTagSprite1];
	CCNode *sp2 = [self getChildByTag:kTagSprite2];
	
	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];
}


-(NSString *) title
{
	return @"remove/cleanup with children";
}
@end


@implementation StressTest1
-(id) init
{
	if( ( self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[self addChild:sp1 z:0 tag:kTagSprite1];
		
		sp1.position = ccp(s.width/2, s.height/2);		

		[self schedule:@selector(shouldNotCrash:) interval:1.0f];
	}
	
	return self;
}

- (void) shouldNotCrash:(ccTime) delta
{	
	[self unschedule:_cmd];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// if the node has timers, it crashes
	CCNode *explosion = [CCParticleSun node];
	
	// if it doesn't, it works Ok.
//	CocosNode *explosion = [Sprite spriteWithFile:@"grossinis_sister2.png"];

	explosion.position = ccp(s.width/2, s.height/2);
	
	[self runAction:[CCSequence actions:
						[CCRotateBy actionWithDuration:2 angle:360],
						[CCCallFuncN actionWithTarget:self selector:@selector(removeMe:)],
						nil]];
	
	[self addChild:explosion];
}

// remove
- (void) removeMe: (id)node
{	
	[parent removeChild:node cleanup:YES];
	[self nextCallback:self];
}


-(NSString *) title
{
	return @"stress test #1: no crashes";
}
@end

@implementation StressTest2
-(id) init
{
	// 
	// Purpose of this test:
	// Objects should be released when a layer is removed
	//
	
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLayer *sublayer = [CCLayer node];
		
		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		sp1.position = ccp(80, s.height/2);
		
		id move = [CCMoveBy actionWithDuration:3 position:ccp(350,0)];
		id move_ease_inout3 = [CCEaseInOut actionWithAction:[[move copy] autorelease] rate:2.0f];
		id move_ease_inout_back3 = [move_ease_inout3 reverse];
		id seq3 = [CCSequence actions: move_ease_inout3, move_ease_inout_back3, nil];
		[sp1 runAction: [CCRepeatForever actionWithAction:seq3]];
		[sublayer addChild:sp1 z:1];
		
		CCParticleFire *fire = [CCParticleFire node];
		fire.position = ccp(80, s.height/2-50);
		id copy_seq3 = [[seq3 copy] autorelease];
		[fire runAction:[CCRepeatForever actionWithAction:copy_seq3]];
		[sublayer addChild:fire z:2];
				
		[self schedule:@selector(shouldNotLeak:) interval:6.0f];
		
		[self addChild:sublayer z:0 tag:kTagSprite1];
	}
	
	return self;
}

- (void) shouldNotLeak:(ccTime)dt
{	
	[self unschedule:_cmd];
	id sublayer = [self getChildByTag:kTagSprite1];
	[sublayer removeAllChildrenWithCleanup:YES];
}

-(NSString *) title
{
	return @"stress test #2: no leaks";
}
@end

@implementation SchedulerTest1
-(id) init
{
	// 
	// Purpose of this test:
	// Scheduler should be released
	//
	
	if( ( self=[super init]) ) {
		CCLayer *layer = [CCLayer node];
		NSLog(@"retain count after init is %d", [layer retainCount]);                // 1
		
		[self addChild:layer z:0];
		NSLog(@"retain count after addChild is %d", [layer retainCount]);      // 2
		
		[layer schedule:@selector(doSomething:)];
		NSLog(@"retain count after schedule is %d", [layer retainCount]);      // 3
		
		[layer unschedule:@selector(doSomething:)];
		NSLog(@"retain count after unschedule is %d", [layer retainCount]);		// STILL 3!
	}
	
	return self;
}
-(void) doSomething:(ccTime)dt
{
}
-(NSString *) title
{
	return @"cocosnode scheduler test #1";
}
@end




#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
			 
	[[CCDirector sharedDirector] runWithScene: scene];
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
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
