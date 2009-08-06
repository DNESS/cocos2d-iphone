/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ParallaxNode.h"
#import "Support/CGPointExtension.h"
#import "Support/ccArray.h"

@interface CGPointObject : NSObject
{
	CGPoint	ratio_;
	CGPoint offset_;
	CocosNode *child_;	// weak ref
}
@property (readwrite) CGPoint ratio;
@property (readwrite) CGPoint offset;
@property (readwrite,assign) CocosNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObject
@synthesize ratio = ratio_;
@synthesize offset = offset_;
@synthesize child=child_;

+(id) pointWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	return [[[self alloc] initWithCGPoint:ratio offset:offset] autorelease];
}
-(id) initWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	if( (self=[super init])) {
		ratio_ = ratio;
		offset_ = offset;
	}
	return self;
}
@end


@implementation ParallaxNode

@synthesize parallaxArray=parallaxArray_;

-(id) init
{
	if( (self=[super init]) ) {
		parallaxArray = ccArrayNew(5);
		
		[self schedule:@selector(updateCoords:)];
		lastPosition = CGPointMake(-100,-100);
	}
	return self;
}

- (void) dealloc
{
	if( parallaxArray ) {
		ccArrayFree(parallaxArray);
		parallaxArray = nil;
	}
	[super dealloc];
}

-(NSString*) addressForObject:(CocosNode*)child
{
	return [NSString stringWithFormat:@"<%08X>", child];
}
-(id) addChild: (CocosNode*) child z:(int)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObject *obj = [CGPointObject pointWithCGPoint:ratio offset:offset];
	obj.child = child;
	ccArrayAppendObject(parallaxArray, obj);
	
	CGPoint pos = self.position;
	float x = pos.x * ratio.x + offset.x;
	float y = pos.y * ratio.y + offset.y;
	child.position = ccp(x,y);
	
	return [super addChild: child z:z tag:child.tag];
}

-(void) removeChild:(CocosNode*)node cleanup:(BOOL)cleanup
{
	for( unsigned int i=0;i < parallaxArray->num;i++) {
		CGPointObject *point = parallaxArray->arr[i];
		if( [point.child isEqual:node] ) {
			ccArrayRemoveObjectAtIndex(parallaxArray, i);
			break;
		}
	}
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	ccArrayRemoveAllObjects(parallaxArray);
	[super removeAllChildrenWithCleanup:cleanup];
}

-(CGPoint) absolutePosition_
{
	CGPoint ret = position_;
	
	CocosNode *cn = self;
	
	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}
	
	return ret;
}

-(void) updateCoords: (ccTime) dt
{
//	CGPoint pos = position_;
//	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	CGPoint pos = [self absolutePosition_];
	if( ! CGPointEqualToPoint(pos, lastPosition) ) {
		
		for(unsigned int i=0; i < parallaxArray->num; i++ ) {

			CGPointObject *point = parallaxArray->arr[i];
			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;			
			point.child.position = ccp(x,y);
		}
		
		lastPosition = pos;
	}
}
@end
