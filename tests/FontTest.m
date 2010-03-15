//
// Font Test
// a cocos2d example
//
// Example by Maarten Billemont (lhunath)

// cocos2d import
#import "cocos2d.h"

// local import
#import "FontTest.h"

#pragma mark Demo - Font

enum {
	kTagLabel1,
	kTagLabel2,
	kTagLabel3,
	kTagLabel4,

};

static int fontIdx=0;
static NSString *fontList[] =
{
	@"American Typewriter",
	@"Marker Felt",
	@"A Damn Mess",
	@"Abberancy",
	@"Abduction",
	@"Paint Boy",
	@"Schwarzwald Regular",
	@"Scissor Cuts",
};

NSString* nextAction()
{	
	fontIdx++;
	fontIdx = fontIdx % ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* backAction()
{
	fontIdx--;
	if( fontIdx < 0 )
		fontIdx += ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* restartAction()
{
	return fontList[fontIdx];
}

@implementation FontLayer
-(id) init
{
	if(!(self=[super init] ))
        return nil;
    
    // menu
    CGSize size = [CCDirector sharedDirector].winSize;
    CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
    CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
    CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
    CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
    menu.position = CGPointZero;
    item1.position = ccp(size.width/2-100,30);
    item2.position = ccp(size.width/2, 30);
    item3.position = ccp(size.width/2+100,30);
    [self addChild: menu z:1];
    
    [self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
    
	return self;
}

- (void)showFont:(NSString *)aFont
{
	
	[self removeChildByTag:kTagLabel1 cleanup:YES];
	[self removeChildByTag:kTagLabel2 cleanup:YES];
	[self removeChildByTag:kTagLabel3 cleanup:YES];
	[self removeChildByTag:kTagLabel4 cleanup:YES];
    
	
	CCLabel *top = [CCLabel labelWithString:aFont fontName:aFont fontSize:24];
	CCLabel *left = [CCLabel labelWithString:@"alignment left" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentLeft fontName:aFont fontSize:32];
	CCLabel *center = [CCLabel labelWithString:@"alignment center" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentCenter fontName:aFont fontSize:32];
	CCLabel *right = [CCLabel labelWithString:@"alignment right" dimensions:CGSizeMake(480,50) alignment:UITextAlignmentRight fontName:aFont fontSize:32];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	top.position = ccp(s.width/2,250);
	left.position = ccp(s.width/2,200);
	center.position = ccp(s.width/2,150);
	right.position = ccp(s.width/2,100);
	
	[[[[self addChild:left z:0 tag:kTagLabel1]
	  addChild:right z:0 tag:kTagLabel2]
	 addChild:center z:0 tag:kTagLabel3]
	 addChild:top z:0 tag:kTagLabel4];
	
//    label = [[Label alloc] initWithString:"This is a test: left" fontName:aFont fontSize:30];
//    label.color = ccc3(0xff, 0xff, 0xff);
//    label.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
	
//	NSLog(@"s: %f, t:%f", [[label texture] maxS], [[label texture] maxT]);
//	[[label texture] setMaxS:1];
//	[[label texture] setMaxT:1];	
}

-(void) nextCallback:(id) sender
{
    [self showFont:nextAction()];
}	

-(void) backCallback:(id) sender
{
    [self showFont:backAction()];
}	

-(void) restartCallback:(id) sender
{
    [self showFont:restartAction()];
}	
@end

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
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];

	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationLandscapeRight];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [FontLayer node]];
	
	[[CCDirector sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window dealloc];
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
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
