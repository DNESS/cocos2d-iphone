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
-(void) actionAllocWithHashElement:(tHashElement*)element;
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
		targets = nil;
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG( @"deallocing %@", self);

	uthash_tbl_free( targets );
	[super dealloc];
}


-(void) actionAllocWithHashElement:(tHashElement*)element
{
	if( element->actions == nil )
		element->actions = ccArrayNew(10);
	else if( element->actions->num == element->actions->max )
		ccArrayDoubleCapacity(element->actions);	
}

-(void) runAction:(Action*) action target:(id)target
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	
	tHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	
	if( ! element ) {
		element = malloc( sizeof( *element ) );
		bzero(element, sizeof(*element));
		element->target = [target retain];
		HASH_ADD_INT( targets, target, element );
	}
	
	[self actionAllocWithHashElement:element];

	NSAssert( !ccArrayContainsObject(element->actions, action), @"runAction: Action already running");	
	ccArrayAppendObject(element->actions, action);
	
	action.target = target;
	[action start];
}

-(void) stopAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	tHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	if( element ) {
		if( ccArrayContainsObject(element->actions, element->currentAction) && !element->currentActionSalvaged ) {
			[element->currentAction retain];
			element->currentActionSalvaged = YES;
		}
		
		ccArrayRemoveAllObjects(element->actions);
	} else {
		CCLOG(@"stopAllActionsFromTarget: Target not found");
	}
}

-(void) stopAction: (Action*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	tHashElement *element = nil;
	id target = action.target;
	HASH_FIND_INT(targets, &target, element);

	if( element ) {
		NSUInteger i = ccArrayGetIndexOfObject(element->actions, action);
		if( i != NSNotFound ) {
			if( action == element->currentAction && !element->currentActionSalvaged ) {
				[element->currentAction retain];
				element->currentActionSalvaged = YES;
			}
			ccArrayRemoveObjectAtIndex(element->actions, i);

			// update actionIndex in case we are in step_, looping over the actions
			if( element->actionIndex >= (int) i )
				element->actionIndex--;
			
			if( element->actions->num == 0 ) {
				ccArrayFree(element->actions);
				HASH_DEL(targets, element);
				[element->target release];
				free(element);
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
	
	tHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);

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

-(Action*) getActionByTag:(int)aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");

	tHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);

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
	tHashElement *element = nil;
	HASH_FIND_INT(targets, &target, element);
	if( element )
		return element->actions ? element->actions->num : 0;

	CCLOG(@"numberOfRunningActionsInTarget: Target not found");
	return 0;
}

-(void) step_: (ccTime) dt
{
    for(tHashElement *element=targets; element != NULL; element=element->hh.next) {	
		
		// The 'actions' ccArray may change while inside this loop.
		for( element->actionIndex = 0; element->actionIndex < (int) element->actions->num; element->actionIndex++) {
			element->currentAction = element->actions->arr[element->actionIndex];
			element->currentActionSalvaged = NO;
			
			[element->currentAction step: dt];

			if( element->currentActionSalvaged ) {
				// The currentAction told the node to stop it. To prevent the action from
				// accidentally deallocating itself before finishing its step, we retained
				// it. Now that step is done, it's safe to release it.
				[element->currentAction release];
			} else if( [element->currentAction isDone] ) {
				[element->currentAction stop];
				
				Action *a = element->currentAction;
				// Make currentAction nil to prevent stopAction from salvaging it.
				element->currentAction = nil;
				[self stopAction:a];
			}
		}
	}
}
@end
