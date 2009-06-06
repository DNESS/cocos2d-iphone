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

#import <UIKit/UIKit.h>
#include <sys/time.h>

#import "ccTypes.h"

enum {
	//! Default tag
	kActionTagInvalid = -1,
};

@class CocosNode;
/** Base class for actions
 */
@interface Action : NSObject <NSCopying> {
	CocosNode *target;
	int tag;
}

/** The "target". The action will modify the target properties */
@property (readwrite,assign) CocosNode *target;
/** The action tag. An identifier of the action */
@property (readwrite,assign) int tag;
/** YES if the action has finished */
@property (readonly,assign) BOOL isDone;

+(id) action;
-(id) init;

-(id) copyWithZone: (NSZone*) zone;

//! called before the action start
-(void) start;
//! called every frame with it's delta time. DON'T override unless you know what you are doing.
-(void) step: (ccTime) dt;

/** returns a reversed action */
- (id) reverse;
@end

/** Repeats an action a number of times.
 @warning This action can't be Eased because it is not an IntervalAction.
 */
@interface GeneralRepeat : Action <NSCopying>
{
	NSUInteger times, total;
	Action *other;
}
/** creates the GeneralRepeat action. Times is an unsigned integer between 1 and pow(2,30) */
+(id) actionWithAction:(Action*)action times: (NSUInteger)times;
/** initializes the action. Times is an unsigned integer between 1 and pow(2,30) */
-(id) initWithAction:(Action*)action times: (NSUInteger)times;
@end


/** Repeats an action forever.
 To repeat the an action for a limited number of times use the Repeat action.
 @warning This action can't be Eased because it is not an IntervalAction.
 */
@interface RepeatForever : GeneralRepeat <NSCopying>
{
}
/** creates the action */
+(id) actionWithAction: (Action*) action;
/** initializes the action */
-(id) initWithAction: (Action*) action;
@end


/** Runs actions sequentially, one after another.
  @warning This action can't be Eased because it is not an IntervalAction.
 */
@interface GeneralSequence : Action <NSCopying>
{
	NSArray *actions;
	Action *currentAction;
	NSUInteger currentActionIndex;
}
/** helper contructor to create an array of sequenceable actions */
+(id) actions: (Action*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the action */
+(id) actionOne:(Action*)actionOne two:(Action*)actionTwo;
/** initializes the action */
-(id) initOne:(Action*)actionOne two:(Action*)actionTwo;
@end


/** Runs actions in parallel.
  @warning This action can't be Eased because it is not an IntervalAction.
 */
@interface GeneralSpawn : Action <NSCopying>
{
	Action *one, *two;
}
/** helper constructor to create an array of spawned actions */
+(id) actions: (Action*) action1, ... NS_REQUIRES_NIL_TERMINATION;
/** creates the Spawn action */
+(id) actionOne: (Action*) one two:(Action*) two;
/** initializes the Spawn action with the 2 actions to spawn */
-(id) initOne: (Action*) one two:(Action*) two;
@end

/** Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1) time.
 Useful to simulate 'slow motion' or 'fast forward' effect.
 @warning This action can't be Eased because it is not an IntervalAction.
 */
@interface Speed : Action <NSCopying>
{
	Action	*other;
	float speed;
}
/** alter the speed of the inner function in runtime */
@property (readwrite) float speed;
/** creates the action */
+(id) actionWithAction: (Action*) action speed:(float)rate;
/** initializes the action */
-(id) initWithAction: (Action*) action speed:(float)rate;
@end
