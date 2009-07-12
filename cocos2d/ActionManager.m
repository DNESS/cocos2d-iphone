/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "ActionManager.h"
#import "Scheduler.h"
#import "ccMacros.h"

//
// singleton stuff
//
static ActionManager *_sharedManager = nil;

@interface ActionManager (Private)
-(void) actionAlloc;
@end


@implementation ActionManager

+ (ActionManager *)sharedManager
{
	@synchronized([ActionManager class])
	{
		if (!_sharedManager)
			[[self alloc] init];
		
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([ActionManager class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	if ((self=[super init]) ) {
		[[Scheduler sharedScheduler] scheduleTimer: [Timer timerWithTarget:self selector:@selector(step_:)]];
		[self actionAlloc];
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);
	
	ccArrayFree(actions);	
	[super dealloc];
}


-(void) actionAlloc
{
	if( actions == nil )
		actions = ccArrayNew(10);
	else if( actions->num == actions->max )
		ccArrayDoubleCapacity(actions);
}

-(void) runAction:(Action*) action target:(id)target
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	NSAssert( !ccArrayContainsObject(actions, action), @"Action already running");
	
	[self actionAlloc];
	
	ccArrayAppendObject(actions, action);
	
	action.target = target;
	[action start];
}

-(void) stopAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	NSUInteger limit = actions->num;
	for( NSUInteger i = 0; i < limit; i++) {
		Action *a = actions->arr[i];
		
		if( a.target == target )
			[self stopAction:a];
	}
}

-(void) stopAction: (Action*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	NSUInteger i = ccArrayGetIndexOfObject(actions, action);
	if( i != NSNotFound ) {
		ccArrayRemoveObjectAtIndex(actions, i);

		// update actionIndex in case we are in step_, looping over the actions
		if( actionIndex >= (int) i )
			actionIndex--;
	}
}

-(void) stopActionByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	NSUInteger limit = actions->num;
	for( NSUInteger i = 0; i < limit; i++) {
		Action *a = actions->arr[i];
		
		if( a.tag == aTag && a.target==target) {
			ccArrayRemoveObjectAtIndex(actions, i);
			
			// update actionIndex in case we are in step_, looping over the actions
			if (actionIndex >= (int) i)
				actionIndex--;
			return; 
		}
	}
	CCLOG(@"stopActionByTag: Action not found!");
}

-(Action*) getActionByTag:(int)aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	
	if( actions != nil ) {
		NSUInteger limit = actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			Action *a = actions->arr[i];
		
			if( a.tag == aTag )
				return a; 
		}
	}

	CCLOG(@"getActionByTag: Action not found");
	return nil;
}

-(int) numberOfRunningActionsInTarget:(id) target
{
	int total = 0;
	for( NSUInteger i=0; i< actions->num ; i++ ) {
		Action *a = actions->arr[i];
		if( a.target == target )
			total++;
	}
	return total;
}

-(void) step_: (ccTime) dt
{
	for( actionIndex = 0; actionIndex < (int) actions->num; actionIndex++) {
		Action *currentAction = actions->arr[actionIndex];
		
		[currentAction step: dt];
		
		if( [currentAction isDone] ) {
			[currentAction stop];
			
			[self stopAction:currentAction];
		}
	}
}
@end
