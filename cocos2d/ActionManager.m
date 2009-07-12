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


@implementation HashElement
@end

//
// singleton stuff
//
static ActionManager *_sharedManager = nil;

@interface ActionManager (Private)
-(void) targetAlloc;
-(void) actionAllocWithHashElement:(HashElement*)element;
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
		[self targetAlloc];
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);

	ccArrayFree( targets );
	[super dealloc];
}

#pragma mark ActionManager - Private
-(HashElement*) findElementWithTarget:(id) target
{
	HashElement *element;
	for( unsigned int i=0; i < targets->num; i++) {
		element = targets->arr[i];
		if (element->target == target )
			return element;
	}
	return nil;
}

-(void) targetAlloc
{
	if( targets == nil )
		targets = ccArrayNew(100);
	else if( targets->num == targets->max )
		ccArrayDoubleCapacity(targets);		
}
-(void) actionAllocWithHashElement:(HashElement*)element
{
	if( element->actions == nil )
		element->actions = ccArrayNew(10);
	else if( element->actions->num == element->actions->max )
		ccArrayDoubleCapacity(element->actions);	
}

#pragma mark ActionManager - Run

-(void) runAction:(Action*) action target:(id)target
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	
	HashElement *element = [self findElementWithTarget:target];	
	if( ! element ) {
		element = [[HashElement alloc] init];
		element->target = [target retain];
		[self targetAlloc];
		ccArrayAppendObject( targets, element );
		[element release];
	}
	
	[self actionAllocWithHashElement:element];

	NSAssert( !ccArrayContainsObject(element->actions, action), @"runAction: Action already running");	
	ccArrayAppendObject(element->actions, action);
	
	action.target = target;
	[action start];
}

#pragma mark ActionManager - Stop

-(void) stopAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	HashElement *element = [self findElementWithTarget:target];
	if( element ) {
		if( ccArrayContainsObject(element->actions, element->currentAction) && !element->currentActionSalvaged ) {
			[element->currentAction retain];
			element->currentActionSalvaged = YES;
		}
		
		if( ccArrayContainsObject(targets, element) && !currentTargetSalvaged) {
			currentTargetSalvaged = YES;
			[currentTarget retain];
		}
		targetIndex--;
		ccArrayFree(element->actions);
		[element->target release];
		ccArrayRemoveObject(targets, element);
	} else {
		CCLOG(@"stopAllActionsFromTarget: Target not found");
	}
}

-(void) stopAction: (Action*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	HashElement *element = [self findElementWithTarget:action.target];
	if( element ) {
		NSUInteger i = ccArrayGetIndexOfObject(element->actions, action);
		if( i != NSNotFound ) {
			if( action == element->currentAction && !element->currentActionSalvaged ) {
				[element->currentAction retain];
				element->currentActionSalvaged = YES;
			}
			ccArrayRemoveObjectAtIndex(element->actions, i);

			// update actionIndex in case we are in step_, looping over the actions
			if( element->actionIndex >= i )
				element->actionIndex--;
			
			if( element->actions->num == 0 ) {
				if( ccArrayContainsObject(targets, element) && !currentTargetSalvaged) {
					currentTargetSalvaged = YES;
					[currentTarget retain];
				}
				
				targetIndex--;
				ccArrayFree(element->actions);
				[element->target release];
				ccArrayRemoveObject(targets, element);
			}
		}
	} else {
		CCLOG(@"stopAction: Target not found");
	}
}

-(void) stopActionByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	HashElement *element = [self findElementWithTarget:target];

	if( element ) {
		NSUInteger limit = element->actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			Action *a = element->actions->arr[i];
			
			if( a.tag == aTag && a.target==target)
				return [self stopAction:a];
		}
		CCLOG(@"stopActionByTag: Action not found!");
	} else {
		CCLOG(@"stopActionByTag: Target not found!");
	}
}

#pragma mark ActionManager - Get

-(Action*) getActionByTag:(int)aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");

	HashElement *element = [self findElementWithTarget:target];
	if( element ) {
		if( element->actions != nil ) {
			NSUInteger limit = element->actions->num;
			for( NSUInteger i = 0; i < limit; i++) {
				Action *a = element->actions->arr[i];
			
				if( a.tag == aTag )
					return a; 
			}
		}
		CCLOG(@"getActionByTag: Action not found");
	} else {
		CCLOG(@"getActionByTag: Target not found");
	}
	return nil;
}

-(int) numberOfRunningActionsInTarget:(id) target
{
	HashElement *element = [self findElementWithTarget:target];
	if( element )
		return element->actions ? element->actions->num : 0;

	CCLOG(@"numberOfRunningActionsInTarget: Target not found");
	return 0;
}

#pragma mark ActionManager - Main loop

-(void) step_: (ccTime) dt
{
	for( targetIndex=0; targetIndex< targets->num ; targetIndex++ ) {
		currentTarget = targets->arr[targetIndex];
		currentTargetSalvaged = NO;
		
		// The 'actions' ccArray may change while inside this loop.
		for( currentTarget->actionIndex = 0; currentTarget->actionIndex <  currentTarget->actions->num; currentTarget->actionIndex++) {
			currentTarget->currentAction = currentTarget->actions->arr[currentTarget->actionIndex];
			currentTarget->currentActionSalvaged = NO;
			
			[currentTarget->currentAction step: dt];

			if( currentTarget->currentActionSalvaged ) {
				// The currentAction told the node to stop it. To prevent the action from
				// accidentally deallocating itself before finishing its step, we retained
				// it. Now that step is done, it's safe to release it.
				[currentTarget->currentAction release];
			} else if( [currentTarget->currentAction isDone] ) {
				[currentTarget->currentAction stop];
				
				Action *a = currentTarget->currentAction;
				// Make currentAction nil to prevent stopAction from salvaging it.
				currentTarget->currentAction = nil;
				[self stopAction:a];
			}
		}
		
		if( currentTargetSalvaged )
			[currentTarget release];
	}
}
@end
