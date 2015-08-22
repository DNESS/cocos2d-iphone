#summary cocos2d for iPhone best practices

# DEPRECATED #
DEPRECATED DEPRECATED

Use this page instead:

http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:best_practices



# Introduction #

iPhone is a very nice device. Although it has very nice and powerful features, you must be careful when programming for it.
So here are the cocos2d (and general) best-practices.

# Details #

## Improving performance ##
  * Use this guide as reference: [perf\_test.pdf](http://cocos2d-iphone.googlecode.com/svn/trunk/tools/perf_test.pdf)
  * Use fast director:
```
    // must be called before any other call to the director
    [Director useFastDirector];
```
  * When possible try to use texture atlas:
    * Use `AtlasSprite` instead of `Sprite`
    * Use `BitmapFontAtlas` or `LabelAtlas` instead of `Label`
    * Use `TileMapAtlas` to render tiles
  * When possible, try to use 4-bit or 16-bit textures
    * 16-bit textures for PNG/GIF/BMP/TIFF images (16-bit textures are the default in v0.8)
```
   [Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
```
    * 4-bit or 2-bit textures: Try to use PVRTC textures.
```
   Sprite *sprite = [Sprite spriteWithFile: @"sprite.pvr"];
```
    * Use 32-bit textures as the last resort

## Reducing Memory ##
  * Use 16-bit or 4-bit textures (see **Improving performance**)
  * Use the `TextureMgr`
    * `TextureMgr` caches all images
    * Even when the image is not used anymore, it will remain in memory
    * To remove it from memory do:
```
   // textures with retain count 1 will be removed
   // you can add this line in your scene#dealloc method
   [[TextureMgr sharedTextureMgr] removeUnusedTextures]; // since v0.8
   
   // removes a certain texture from the cache
   Texture2D *texture = [sprite texture];
   [[TextureMgr sharedTextureMgr] removeTexture: texture]]; // available in v0.7 too

   // removes all textures... only use when you receive a memory warning signal
   [[TextureMgr sharedTextureMgr] removeAllTextures];    // available in v0.7 too

```

## Timers ##
  * Try not to use Cocoa's NSTimers. Instead use cocos2d's own scheduler.
  * If you use cocos2d scheduler, you will have:
    * automatic pause/resume.
    * when the Layer (Scene, Sprite, CocosNode) enters the stage the timer will be automatically activated, and when it leaves the stage it will be automatically deactivated.
    * Your target/selector will be called with a _delta_ _time_
```
/**********************************************************/
// OK OK OK OK OK
/**********************************************************/
-(id) init
{
	if( ! [super init] )
		return nil;

	// schedule timer
	[self schedule: @selector(tick:)];
	[self schedule: @selector(tick2:) interval:0.5];

	return self;
}

-(void) tick: (ccTime) dt
{
	// bla bla bla
}

-(void) tick2: (ccTime) dt
{
	// bla bla bla
}

/**********************************************************/
// BAD BAD BAD BAD
/**********************************************************/
// Why BAD ?
// You can't pause the game automagically.
-(void) onEnter
{
	[super onEnter];
	timer1 = [NSTimer scheduledTimerWithTimeInterval:1/FPS target:self selector:@selector(tick1) userInfo:nil repeats:YES];
	timer2 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tick2) userInfo:nil repeats:YES];
}
-(void) onExit
{
	[timer1 invalidate];
	[timer2 invalidate];
	[super onExit];
}
-(void) tick
{
	// bla bla bla
}

-(void) tick2
{
	// bla bla bla
}

```

## draw vs update ##
  * try not to update any state variable inside the _draw_ selector.
  * try not to draw anything inside a scheduled selector
  * Instead update the state variables inside a scheduled selector.
  * Instead draw everything inside the _draw_ selector
  * If you update state variables inside the _draw_ selector, the pause/resume won't work as expected.
  * If you draw something inside a scheduled selector, it can't be _transformed_
  * _draw_ is called every frame
  * scheduled selectors can be called with any frame rate, but no more frequently than the application's FPS rate.
```
/**********************************************************/
// OK OK OK OK OK
/**********************************************************/
-(void) draw
{
	[item draw];	// OK: DRAW INSIDE DRAW
}
-(void) tick:(ccTime) dt
{
	item.position = dt * finalPosition; // OK, UPDATE STATE IN SCHEDULED SELECTOR
}

/**********************************************************/
// BAD BAD BAD BAD 1 
/**********************************************************/
-(void) draw
{
	dt = [self calculateDelta];         // DONT UPDATE STATE IN DRAW.
        item.position = dt * finalPosition; // Pause won't work

	[item draw];
}

/**********************************************************/
// BAD BAD BAD BAD 2
/**********************************************************/
-(void) tick:(ccTime) dt
{
	item.position = dt * finalPosition;
	[item draw];		// <--- DON'T DRAW IN SCHEDULED SELECTOR
                                // because transformations won't alter your image
}

```

## Director flow control ##
  * If possible try to use _replaceScene_ instead of _pushScene_
  * _pushScene_ is very handy, but it will put the _pushed_ scene into memory, and memory is a precious resource in the iPhone.
```
// TRY TO AVOID A BIG STACK OF PUSHED SCENES
-(void) mainMenu()
{
      // etc
      [[Director sharedDirector] pushScene: gameScene];
}
// stack:
//   . game  <-- running scene
//   . mainMenu

-(void) game
{
      [[Director sharedDirector] pushScene: gameOverScene];
}
// stack:
//   . gameOver  <-- running scene
//   . game
//   . mainMenu

-(void) showGameOver
{
      [[Director sharedDirector] pushScene: hiScoreScene];
}
// stack:
//   . scores  <-- running scene (4 pushed scenes... expensive)
//   . gameOver
//   . game
//   . mainMenu

```

## Creating Nodes (Sprites, Labels, etc..) ##
  * When possible try to create CocosNodes (Sprites, Labels, Layers, etc) or any other kind of object in the _init_ selector and not in the _draw_ and any other scheduled selector
  * The creation of nodes is expensive, so try to have them pre-created
  * On the other hand, be careful with the memory. Don't have in memory unnecessary objects.
```
/**********************************************************/
// OK, MOST OF THE TIME
/**********************************************************/
-(id) init
{
	// etc...

	sprite1 = [Sprite1 create];	// <-- USUALLY IT IS BETTER TO CREATE OBJECTS IN INIT

	// etc...
}

-(void) tick: (ccTime) dt
{
	// etc...
	if( someThing ) {
		[sprite1 show];		// <--- BUT IF YOU DON'T USE THEM FREQUENTLY, MEMORY IS WASTED

	}

}

/**********************************************************/
// BAD, MOST OF THE TIME
/**********************************************************/
-(void) tick: (ccTime) dt
{
	// etc...
	if( someThing ) {
		sprite = [Sprite1 create];	// <--- EXEPENSIVE
		[sprite1 show];

		//...

		[sprite1 release];	// <- AT LEAST MEMORY IS RELEASED
	}

}


```



## Hierarchy of Layers ##
  * Don't create a big hierarchy of layers. Try to keep them low when possible.
```
```

## Actions ##
  * It is expensive to create certain actions, since it might require a lot of `mallocs()`. For example: A `Sequence` of a `Spawn` with a `RotateBy` with a another `Sequence`, etc... is very expensive.
  * So try to reuse actions.
  * Once the action is used, save it for later if you know you will execute that type of action again. Then, instead of `allocing` a new action, you can just `initialize` it.

## Buttons ##
  * Use a `Menu` with a `MenuItemImage` and place your menu using `menu.position = ccp(x,y)`. See the `MenuTest` example for more details.

## how does the pause/resume works ? ##
  * when the director receives the _pause_ message it won't call any scheduled target/selector.
  * but the _draw_ selector will be called at a rate of 4 FPS (to reduce battery consumption)
  * when the director receives the _resume_ message, the scheduled target/selectors will be called again every frame.
```
```