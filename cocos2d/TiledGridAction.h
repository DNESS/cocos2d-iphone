/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 On-Core
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCGridAction.h"

/** ShakyTiles3D action */
@interface CCShakyTiles3D : CCTiledGrid3DAction
{
	int		randrange;
	BOOL	shakeZ;
}

/** creates the action with a range, whether or not to shake Z vertices, a grid size, and duration */
+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a range, whether or not to shake Z vertices, a grid size, and duration */
-(id)initWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** ShatteredTiles3D action */
@interface CCShatteredTiles3D : CCTiledGrid3DAction
{
	int		randrange;
	BOOL	once;
	BOOL	shatterZ;
}

/** creates the action with a range, whether of not to shatter Z vertices, a grid size and duration */
+(id)actionWithRange:(int)range shatterZ:(BOOL)shatterZ grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a range, whether or not to shatter Z vertices, a grid size and duration */
-(id)initWithRange:(int)range shatterZ:(BOOL)shatterZ grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** ShuffleTiles action
 Shuffle the tiles in random order
 */
@interface CCShuffleTiles : CCTiledGrid3DAction
{
	int	seed;
	int tilesCount;
	int *tilesOrder;
	void *tiles;
}

/** creates the action with a random seed, the grid size and the duration */
+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a random seed, the grid size and the duration */
-(id)initWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** FadeOutTRTiles action
 Fades out the tiles in a Top-Right direction
 */
@interface CCFadeOutTRTiles : CCTiledGrid3DAction
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutBLTiles action.
 Fades out the tiles in a Bottom-Left direction
 */
@interface CCFadeOutBLTiles : CCFadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutUpTiles action.
 Fades out the tiles in upwards direction
 */
@interface CCFadeOutUpTiles : CCFadeOutTRTiles
{
}
@end

////////////////////////////////////////////////////////////

/** FadeOutDownTiles action.
 Fades out the tiles in downwards direction
 */
@interface CCFadeOutDownTiles : CCFadeOutUpTiles
{
}
@end

////////////////////////////////////////////////////////////

/** TurnOffTiles action.
 Turn off the files in random order
 */
@interface CCTurnOffTiles : CCTiledGrid3DAction
{
	int	seed;
	int tilesCount;
	int *tilesOrder;
}

/** creates the action with a random seed, the grid size and the duration */
+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a random seed, the grid size and the duration */
-(id)initWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d;
@end

////////////////////////////////////////////////////////////

/** WavesTiles3D action. */
@interface CCWavesTiles3D : CCTiledGrid3DAction
{
	int waves;
	float amplitude;
	float amplitudeRate;
}

/** waves amplitude */
@property (nonatomic,readwrite) float amplitude;
/** waves amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with a number of waves, the waves amplitude, the grid size and the duration */
+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with a number of waves, the waves amplitude, the grid size and the duration */
-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** JumpTiles3D action.
 A sin function is executed to move the tiles across the Z axis
 */
@interface CCJumpTiles3D : CCTiledGrid3DAction
{
	int jumps;
	float amplitude;
	float amplitudeRate;
}

/** amplitude of the sin*/
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with the number of jumps, the sin amplitude, the grid size and the duration */
+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;
/** initializes the action with the number of jumps, the sin amplitude, the grid size and the duration */
-(id)initWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** SplitRows action */
@interface CCSplitRows : CCTiledGrid3DAction
{
	CGSize	winSize;
}
/** creates the action with the number of rows to split and the duration */
+(id)actionWithRows:(int)r duration:(ccTime)d;
/** initializes the action with the number of rows to split and the duration */
-(id)initWithRows:(int)r duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** SplitCols action */
@interface CCSplitCols : CCTiledGrid3DAction
{
	CGSize	winSize;
}
/** creates the action with the number of columns to split and the duration */
+(id)actionWithCols:(int)c duration:(ccTime)d;
/** initializes the action with the number of columns to split and the duration */
-(id)initWithCols:(int)c duration:(ccTime)d;

@end
