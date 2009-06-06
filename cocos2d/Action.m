/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "Action.h"
#import "CocosNode.h"
#import "ccMacros.h"

//
// Action Base Class
//
#pragma mark -
#pragma mark Action
@implementation Action

@synthesize target;
@synthesize tag;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( !(self=[super init]) )
		return nil;
	
	target = nil;
	tag = kActionTagInvalid;
	return self;
}

-(void) dealloc
{
	CCLOG(@"deallocing %@", self);
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] init];
	copy.target = target;
	copy.tag = tag;
	return copy;
}

-(void) start
{
	// override me
}

-(void) step: (ccTime) dt
{
	NSAssert(NO, @"Action#step must be overridden by subclass");
}

-(BOOL) isDone
{
	NSAssert(NO, @"Action#isDone must be overridden by subclass");
	return NO;
}

-(id) reverse
{
	NSException* myException = [NSException
															exceptionWithName:@"ReverseActionNotImplemented"
															reason:@"Reverse Action not implemented"
															userInfo:nil];
	@throw myException;
}

@end

//
// GeneralRepeat
//
#pragma mark -
#pragma mark GeneralRepeat
@implementation GeneralRepeat
+(id) actionWithAction:(Action*)action times: (NSUInteger)times;
{
	return [[[self alloc] initWithAction: action times: times] autorelease];
}

-(id) initWithAction:(Action*)action times: (NSUInteger)times_;
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	times = times_; total = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] times: times];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) step:(ccTime) dt
{
	[other step: dt];
	if( [other isDone] ) {
		if( ++total < times )
			[other start];
	}
}

-(BOOL) isDone
{
	return total == times;
}

- (id) reverse
{
	return [GeneralRepeat actionWithAction:[other reverse] times:times];
}
@end

//
// RepeatForever
//
#pragma mark -
#pragma mark RepeatForever
@implementation RepeatForever
+(id) actionWithAction: (Action*) action
{
	return [[[self alloc] initWithAction: action] autorelease];
}

-(id) initWithAction: (Action*) action
{
	return [super initWithAction:action times:NSUIntegerMax];
}
@end


//
// GeneralSequence
//
#pragma mark -
#pragma mark GeneralSequence
@implementation GeneralSequence
+(id) actionOne: (Action*) one two: (Action*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

+(id) actions: (Action*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	Action *now;
	Action *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,Action*);
		if ( now )
			prev = [GeneralSequence actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

-(id) initOne: (Action*) one_ two: (Action*) two_
{
	if ((self = [super init]) == nil) return nil;
	
	NSAssert( one_!=nil, @"Sequence: argument one must be non-nil");
	NSAssert( two_!=nil, @"Sequence: argument two must be non-nil");
	
	Action *one = one_;
	Action *two = two_;
	
	actions = [[NSArray arrayWithObjects: one, two, nil] retain];
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initOne:[[[actions objectAtIndex:0] copy] autorelease] two:[[[actions objectAtIndex:1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[actions release];
	[super dealloc];
}

-(void) start
{
	[super start];
	for( Action *a in actions )
		a.target = target;
	
	currentActionIndex = 0;
	currentAction = [actions objectAtIndex:currentActionIndex];
	[currentAction start];
}

-(void) step:(ccTime) dt
{
	[currentAction step:dt];
	
	if( currentAction.isDone ) {
		if( ++currentActionIndex < [actions count] ) {
			currentAction = [actions objectAtIndex:currentActionIndex];
			[currentAction start];
		}
	}
}

- (BOOL)isDone
{
	return currentActionIndex == [actions count];
}

- (id) reverse
{
	return [GeneralSequence actionOne: [[actions objectAtIndex:1] reverse] two: [[actions objectAtIndex:0] reverse ] ];
}

@end


//
// GeneralSpawn
//
#pragma mark -
#pragma mark GeneralSpawn

@implementation GeneralSpawn
+(id) actions: (Action*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	Action *now;
	Action *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,Action*);
		if ( now )
			prev = [GeneralSpawn actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionOne: (Action*) one two: (Action*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (Action*) one_ two: (Action*) two_
{
	NSAssert( one_!=nil, @"Spawn: argument one must be non-nil");
	NSAssert( two_!=nil, @"Spawn: argument two must be non-nil");
	
	one = [one_ retain]; two = [two_ retain];
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	id copy = [[[self class] allocWithZone: zone] initOne:[[one copy] autorelease] two:[[two copy] autorelease]];
	return copy;
}

-(void) dealloc
{
	[one release]; [two release];
	[super dealloc];
}

-(void) start
{
	[super start];
	one.target = target; two.target = target;
	[one start]; [two start];
}

-(void) step: (ccTime) dt
{
	if( !one.isDone ) [one step:dt];
	if( !two.isDone ) [two step:dt];
}

-(BOOL) isDone
{
	return one.isDone && one.isDone;
}

- (id) reverse
{
	return [GeneralSpawn actionOne:[one reverse] two:[two reverse]];
}
@end


//
// Speed
//
#pragma mark -
#pragma mark Speed
@implementation Speed
@synthesize speed;

+(id) actionWithAction: (Action*) action speed:(float)r
{
	return [[[self alloc] initWithAction: action speed:r] autorelease];
}

-(id) initWithAction: (Action*) action speed:(float)r
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	speed = r;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] speed:speed];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) step:(ccTime) dt
{
	[other step: dt * speed];
}

-(BOOL) isDone
{
	return [other isDone];
}

- (id) reverse
{
	return [Speed actionWithAction:[other reverse] speed:speed];
}
@end
