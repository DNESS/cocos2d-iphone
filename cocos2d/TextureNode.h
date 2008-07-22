/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import <UIKit/UIKit.h>

#import "Texture2D.h"

#import "CocosNode.h"


/** A node that knows how to render a texture */
@interface TextureNode : CocosNode <CocosNodeOpacity> {

	/* OpenGL name for the sprite texture */
	Texture2D *texture;
	
	/// sprite opacity
	GLubyte opacity;
}

@property (readwrite,assign) Texture2D *texture;
@property (readwrite,assign) GLubyte opacity;

-(void) draw;
@end