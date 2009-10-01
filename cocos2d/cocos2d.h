/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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


/** @mainpage cocos2d for iPhone API reference
 *
 * @image html Icon.png
 *
 * @section intro Introduction
 * This is cocos2d API reference
 *
 * The programming guide is hosted here: http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:index
 *
 * <hr>
 *
 * @todo A native english speaker should check the grammar. We need your help!
 *
 */

// 0x00 HI ME LO
// 00   00 08 02
#define COCOS2D_VERSION 0x00000802

//
// all cocos2d include files
//
#import "Action.h"
#import "Camera.h"
#import "CameraAction.h"
#import "CCNode.h"
#import "Director.h"
#import "TouchDispatcher.h"
#import "TouchDelegateProtocol.h"
#import "InstantAction.h"
#import "IntervalAction.h"
#import "EaseAction.h"
#import "CCLabel.h"
#import "CCLayer.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import "ParticleSystem.h"
#import "PointParticleSystem.h"
#import "QuadParticleSystem.h"
#import "ParticleExamples.h"
#import "DrawingPrimitives.h"
#import "CCScene.h"
#import "Scheduler.h"
#import "CCSprite.h"
#import "TextureMgr.h"
#import "CCTextureNode.h"
#import "Transition.h"
#import "TextureAtlas.h"
#import "CCLabelAtlas.h"
#import "TileMapAtlas.h"
#import "CCAtlasNode.h"
#import "EaseAction.h"
#import "TiledGridAction.h"
#import "Grabber.h"
#import "Grid.h"
#import "Grid3DAction.h"
#import "GridAction.h"
#import "CCAtlasSprite.h"
#import "CCAtlasSpriteManager.h"
#import "CCBitmapFontAtlas.h"
#import "CCParallaxNode.h"
#import "ActionManager.h"
#import "CCTMXTiledMap.h"
#import "RenderTexture.h"
#import "MotionStreak.h"
#import "PageTurn3DAction.h"
#import "CCPageTurnTransition.h"

//
// cocos2d macros
//
#import "ccTypes.h"
#import "ccMacros.h"

//
// cocos2d helper files
//
#import "Support/OpenGL_Internal.h"
#import "Support/Texture2D.h"
#import "Support/EAGLView.h"
#import "Support/FileUtils.h"
#import "Support/CGPointExtension.h"
#import "FontManager.h"


// free functions
NSString * cocos2dVersion(void);
