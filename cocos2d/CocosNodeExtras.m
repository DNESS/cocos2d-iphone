/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CocosNodeExtras.h"
#import "Director.h"
#import "ccMacros.h"

void CGAffineToGL(const CGAffineTransform *t, GLfloat *m)
{
	// | m[0] m[4] m[8]  m[12] |     | m11 m21 m31 m41 |     | a c 0 tx |
	// | m[1] m[5] m[9]  m[13] |     | m12 m22 m32 m42 |     | b d 0 ty |
	// | m[2] m[6] m[10] m[14] | <=> | m13 m23 m33 m43 | <=> | 0 0 1  0 |
	// | m[3] m[7] m[11] m[15] |     | m14 m24 m34 m44 |     | 0 0 0  1 |
	
	m[2] = m[3] = m[6] = m[7] = m[8] = m[9] = m[11] = m[14] = 0.0f;
	m[10] = m[15] = 1.0f;
	m[0] = t->a; m[4] = t->c; m[12] = t->tx;
	m[1] = t->b; m[5] = t->d; m[13] = t->ty;
}

void GLToCGAffine(const GLfloat *m, CGAffineTransform *t)
{
	t->a = m[0]; t->c = m[4]; t->tx = m[12];
	t->b = m[1]; t->d = m[5]; t->ty = m[13];
}

@implementation CocosNode (CocosExtrasTransforms)

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty ) {
	
		transform = CGAffineTransformIdentity;
		
		if ( !_relativeTransformAnchor ) {
			transform = CGAffineTransformTranslate(transform, _transformAnchor.x, _transformAnchor.y);
		}
		
		transform = CGAffineTransformTranslate(transform, _position.x, _position.y);
		transform = CGAffineTransformRotate(transform, -CC_DEGREES_TO_RADIANS(_rotation));
		transform = CGAffineTransformScale(transform, _scaleX, _scaleY);
		
		transform = CGAffineTransformTranslate(transform, -_transformAnchor.x, -_transformAnchor.y);
		
		isTransformDirty = NO;
	}
	
	return transform;
}

- (CGAffineTransform)parentToNodeTransform
{
	if ( isInverseDirty ) {
		inverse = CGAffineTransformInvert([self nodeToParentTransform]);
		isInverseDirty = NO;
	}
	
	return inverse;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
	
	for (CocosNode *p = parent; p != nil; p = p.parent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
	
	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	return CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	return CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return cpvsub(nodePoint, _transformAnchor);
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint = cpvadd(nodePoint, _transformAnchor);
	return [self convertToWorldSpace:nodePoint];
}

// convenience methods which take a UITouch instead of CGPoint

- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[Director sharedDirector] convertCoordinate: point];
	return [self convertToNodeSpaceAR:point];
}

@end
