/* Copyright (c) 2007 Scott Lembcke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <limits.h>
#include <string.h>

#import "cocos2d.h"

#include "chipmunk.h"
#include "drawSpace.h"

/*
	IMPORTANT - READ ME!
	
	This file sets up a simple interface that the individual demos can use to get
	a Chipmunk space running and draw what's in it. In order to keep the Chipmunk
	examples clean and simple, they contain no graphics code. All drawing is done
	by accessing the Chipmunk structures at a very low level. It is NOT
	recommended to write a game or application this way as it does not scale
	beyond simple shape drawing and is very dependent on implementation details
	about Chipmunk which may change with little to no warning.
*/

#define LINE_COLOR 0.0f, 0.0f, 0.0f, 1.0f
#define COLLISION_COLOR 1.0f, 0.0f, 0.0f, 1.0f
#define BODY_COLOR 0.0f, 0.0f, 1.0f

static void
glColor_from_pointer(void *ptr)
{
	unsigned long val = (long)ptr;
	
	// hash the pointer up nicely
	val = (val+0x7ed55d16) + (val<<12);
	val = (val^0xc761c23c) ^ (val>>19);
	val = (val+0x165667b1) + (val<<5);
	val = (val+0xd3a2646c) ^ (val<<9);
	val = (val+0xfd7046c5) + (val<<3);
	val = (val^0xb55a4f09) ^ (val>>16);
	
//	GLfloat v = (GLfloat)val/(GLfloat)ULONG_MAX;
//	v = 0.95f - v*0.15f;
//	
//	glColor3f(v, v, v);

	GLubyte r = (val>>0) & 0xFF;
	GLubyte g = (val>>8) & 0xFF;
	GLubyte b = (val>>16) & 0xFF;
	
	GLubyte max = r>g ? (r>b ? r : b) : (g>b ? g : b);
	
	const int mult = 127;
	const int add = 63;
	r = (r*mult)/max + add;
	g = (g*mult)/max + add;
	b = (b*mult)/max + add;
	
	glColor4ub(r, g, b, 255);
}

static const GLfloat circleVAR[] = {
	 0.0000f,  1.0000f,
	 0.2588f,  0.9659f,
	 0.5000f,  0.8660f,
	 0.7071f,  0.7071f,
	 0.8660f,  0.5000f,
	 0.9659f,  0.2588f,
	 1.0000f,  0.0000f,
	 0.9659f, -0.2588f,
	 0.8660f, -0.5000f,
	 0.7071f, -0.7071f,
	 0.5000f, -0.8660f,
	 0.2588f, -0.9659f,
	 0.0000f, -1.0000f,
	-0.2588f, -0.9659f,
	-0.5000f, -0.8660f,
	-0.7071f, -0.7071f,
	-0.8660f, -0.5000f,
	-0.9659f, -0.2588f,
	-1.0000f, -0.0000f,
	-0.9659f,  0.2588f,
	-0.8660f,  0.5000f,
	-0.7071f,  0.7071f,
	-0.5000f,  0.8660f,
	-0.2588f,  0.9659f,
	 0.0000f,  1.0000f,
	 0.0f, 0.0f, // For an extra line to see the rotation.
};
static const int circleVAR_count = sizeof(circleVAR)/sizeof(GLfloat)/2;

static void
drawCircleShape(cpBody *body, cpCircleShape *circle)
{
	glVertexPointer(2, GL_FLOAT, 0, circleVAR);

	glEnableClientState(GL_VERTEX_ARRAY);
	glPushMatrix(); {
		cpVect center = cpvadd(body->p, cpvrotate(circle->c, body->rot));
		glTranslatef(center.x, center.y, 0.0f);
		glRotatef(body->a*180.0f/(cpFloat)M_PI, 0.0f, 0.0f, 1.0f);
		glScalef(circle->r, circle->r, 1.0f);
		
		if(!circle->shape.sensor){
			glColor_from_pointer(circle);
			glDrawArrays(GL_TRIANGLE_FAN, 0, circleVAR_count - 1);
		}
		
		glColor4f(LINE_COLOR);
		glDrawArrays(GL_LINE_STRIP, 0, circleVAR_count);
	} glPopMatrix();
	glDisableClientState(GL_VERTEX_ARRAY);

}

static const GLfloat pillVAR[] = {
	 0.0000f,  1.0000f,
	 0.2588f,  0.9659f,
	 0.5000f,  0.8660f,
	 0.7071f,  0.7071f,
	 0.8660f,  0.5000f,
	 0.9659f,  0.2588f,
	 1.0000f,  0.0000f,
	 0.9659f, -0.2588f,
	 0.8660f, -0.5000f,
	 0.7071f, -0.7071f,
	 0.5000f, -0.8660f,
	 0.2588f, -0.9659f,
	 0.0000f, -1.0000f,

	 0.0000f, -1.0000f,
	-0.2588f, -0.9659f,
	-0.5000f, -0.8660f,
	-0.7071f, -0.7071f,
	-0.8660f, -0.5000f,
	-0.9659f, -0.2588f,
	-1.0000f, -0.0000f,
	-0.9659f,  0.2588f,
	-0.8660f,  0.5000f,
	-0.7071f,  0.7071f,
	-0.5000f,  0.8660f,
	-0.2588f,  0.9659f,
	 0.0000f,  1.0000f,
};
static const int pillVAR_count = sizeof(pillVAR)/sizeof(GLfloat)/2;

static void
drawSegmentShape(cpBody *body, cpSegmentShape *seg)
{
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	
	if(seg->r){
		cpVect delta = cpvsub(b, a);
		cpFloat len = cpvlength(delta)/seg->r;
		
		GLfloat VAR[pillVAR_count*2];
		memcpy(VAR, pillVAR, sizeof(pillVAR));
		
		for(int i=0, half=pillVAR_count; i<half; i+=2)
			VAR[i] += len;
			
		glVertexPointer(2, GL_FLOAT, 0, VAR);
		glEnableClientState(GL_VERTEX_ARRAY);
		glPushMatrix(); {
			GLfloat x = a.x;
			GLfloat y = a.y;
			GLfloat cos = delta.x/len;
			GLfloat sin = delta.y/len;

			const GLfloat matrix[] = {
				 cos,  sin, 0.0f, 0.0f,
				-sin,  cos, 0.0f, 0.0f,
				0.0f, 0.0f, 1.0f, 1.0f,
					 x,    y, 0.0f, 1.0f,
			};
			
			glMultMatrixf(matrix);
				
			if(!seg->shape.sensor){
				glColor_from_pointer(seg);
				glDrawArrays(GL_TRIANGLE_FAN, 0, pillVAR_count);
			}
			
			glColor4f(LINE_COLOR);
			glDrawArrays(GL_LINE_LOOP, 0, pillVAR_count);
		} glPopMatrix();
		glDisableClientState(GL_VERTEX_ARRAY);
	} else {
		glColor4f(LINE_COLOR);
		ccDrawLine( a,b);
	}
}

static void
drawPolyShape(cpBody *body, cpPolyShape *poly)
{
	int count = count=poly->numVerts;
	GLfloat VAR[count*2];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, VAR);

	cpVect *verts = poly->verts;
	for(int i=0; i<count; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		VAR[2*i    ] = v.x;
		VAR[2*i + 1] = v.y;
	}
	

	if(!poly->shape.sensor){
		glColor_from_pointer(poly);
		glDrawArrays(GL_TRIANGLE_FAN, 0, count);
	}
	
	glColor4f(LINE_COLOR);
	glDrawArrays(GL_LINE_LOOP, 0, count);
	
	glDisableClientState(GL_VERTEX_ARRAY);
}

static void
drawObject(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;
	cpBody *body = shape->body;
	
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(body, (cpCircleShape *)shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(body, (cpSegmentShape *)shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(body, (cpPolyShape *)shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}

static const GLfloat springVAR[] = {
	0.00f, 0.0f,
	0.20f, 0.0f,
	0.25f, 3.0f,
	0.30f,-6.0f,
	0.35f, 6.0f,
	0.40f,-6.0f,
	0.45f, 6.0f,
	0.50f,-6.0f,
	0.55f, 6.0f,
	0.60f,-6.0f,
	0.65f, 6.0f,
	0.70f,-3.0f,
	0.75f, 6.0f,
	0.80f, 0.0f,
	1.00f, 0.0f,
};
static const int springVAR_count = sizeof(springVAR)/sizeof(GLfloat)/2;

static void
drawSpring(cpDampedSpring *spring, cpBody *body_a, cpBody *body_b)
{
	cpVect a = cpvadd(body_a->p, cpvrotate(spring->anchr1, body_a->rot));
	cpVect b = cpvadd(body_b->p, cpvrotate(spring->anchr2, body_b->rot));

	glPointSize(5.0f);
	ccDrawLine( a,b);

	cpVect delta = cpvsub(b, a);

	glEnableClientState(GL_VERTEX_ARRAY);

	glVertexPointer(2, GL_FLOAT, 0, springVAR);
	glPushMatrix(); {
		GLfloat x = a.x;
		GLfloat y = a.y;
		GLfloat cos = delta.x;
		GLfloat sin = delta.y;
		GLfloat s = 1.0f/cpvlength(delta);

		const GLfloat matrix[] = {
			 cos,  sin, 0.0f, 0.0f,
			-sin*s,  cos*s, 0.0f, 0.0f,
			0.0f, 0.0f, 1.0f, 1.0f,
				 x,    y, 0.0f, 1.0f,
		};
		
		glMultMatrixf(matrix);
		glDrawArrays(GL_LINE_STRIP, 0, springVAR_count);
	} glPopMatrix();
	glDisableClientState(GL_VERTEX_ARRAY);

}

static void
drawConstraint(cpConstraint *constraint)
{
	cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;

	const cpConstraintClass *klass = constraint->klass;
	if(klass == cpPinJointGetClass()){
		cpPinJoint *joint = (cpPinJoint *)constraint;
	
		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(5.0f);
		ccDrawPoint(a);
		ccDrawPoint(b);

		ccDrawLine(a,b);
	} else if(klass == cpSlideJointGetClass()){
		cpSlideJoint *joint = (cpSlideJoint *)constraint;
	
		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(5.0f);
		ccDrawPoint(a);
		ccDrawPoint(b);

		ccDrawLine(a,b);
	} else if(klass == cpPivotJointGetClass()){
		cpPivotJoint *joint = (cpPivotJoint *)constraint;
	
		cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
		cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(10.0f);
		ccDrawPoint(a);
		ccDrawPoint(b);
	} else if(klass == cpGrooveJointGetClass()){
		cpGrooveJoint *joint = (cpGrooveJoint *)constraint;
	
		cpVect a = cpvadd(body_a->p, cpvrotate(joint->grv_a, body_a->rot));
		cpVect b = cpvadd(body_a->p, cpvrotate(joint->grv_b, body_a->rot));
		cpVect c = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));

		glPointSize(5.0f);
		ccDrawPoint(c);
		ccDrawLine(a,b);
	} else if(klass == cpDampedSpringGetClass()){
		drawSpring((cpDampedSpring *)constraint, body_a, body_b);
	} else {
//		printf("Cannot draw constraint\n");
	}
}

static void
drawBB(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;

	CGPoint vertices[] = {
		{shape->bb.l, shape->bb.b},
		{shape->bb.l, shape->bb.t},
		{shape->bb.r, shape->bb.t},
		{shape->bb.r, shape->bb.b},
	};

	ccDrawPoly(vertices, 4, NO);
}

static void
drawCollisions(void *ptr, void *data)
{
	cpArbiter *arb = (cpArbiter *)ptr;
	for(int i=0; i<arb->numContacts; i++){
		cpVect v = arb->contacts[i].p;
		ccDrawPoint(v);
	}
}

// copied from cpSpaceHash.c
static inline cpHashValue
hash_func(cpHashValue x, cpHashValue y, cpHashValue n)
{
	return (x*1640531513ul ^ y*2654435789ul) % n;
}

static void
drawSpatialHash(cpSpaceHash *hash)
{
	cpBB bb = cpBBNew(-320, -240, 320, 240);
	
	cpFloat dim = hash->celldim;
	int n = hash->numcells;
	
	int l = (int)floor(bb.l/dim);
	int r = (int)floor(bb.r/dim);
	int b = (int)floor(bb.b/dim);
	int t = (int)floor(bb.t/dim);
	
	for(int i=l; i<=r; i++){
		for(int j=b; j<=t; j++){
			int cell_count = 0;
			
			int index = hash_func(i,j,n);
			for(cpSpaceHashBin *bin = hash->table[index]; bin; bin = bin->next)
				cell_count++;
			
			GLfloat v = 1.0f - (GLfloat)cell_count/10.0f;
			glColor4f(v,v,v,1.0f);
//			glRectf(i*dim, j*dim, (i + 1)*dim, (j + 1)*dim);
		}
	}
}

void
drawSpace(cpSpace *space, drawSpaceOptions *options)
{
	if(options->drawHash)
		drawSpatialHash(space->activeShapes);
	
	glLineWidth(1.0f);
	if(options->drawBBs){
		glColor4f(0.3f, 0.5f, 0.3f, 1.0f);
		cpSpaceHashEach(space->activeShapes, &drawBB, NULL);
		cpSpaceHashEach(space->staticShapes, &drawBB, NULL);
	}

	glLineWidth(options->lineThickness);
	if(options->drawShapes){
		cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
		cpSpaceHashEach(space->staticShapes, &drawObject, NULL);
	}
	
	cpArray *constraints = space->constraints;

	glColor4f(0.5f, 1.0f, 0.5f, 1.0f);
	for(int i=0, count = constraints->num; i<count; i++){
		drawConstraint(constraints->arr[i]);
	}
	
	if(options->bodyPointSize){
		cpArray *bodies = space->bodies;

		glPointSize(options->bodyPointSize);
		glColor4f(LINE_COLOR);
		for(int i=0, count = bodies->num; i<count; i++){
			cpBody *body = (cpBody *)bodies->arr[i];
			ccDrawPoint(body->p);
		}
	}

	if(options->collisionPointSize){
		glPointSize(options->collisionPointSize);
		glColor4f(COLLISION_COLOR);
		cpArrayEach(space->arbiters, &drawCollisions, NULL);
	}
}
