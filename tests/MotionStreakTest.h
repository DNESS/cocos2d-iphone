#import <UIKit/UIKit.h>
#import "CCNode.h"
#import "MotionStreak.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface MotionStreakTest : CCLayer
{}

-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface Test1 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
	MotionStreak* streak;
}
@end

@interface Test2 : MotionStreakTest
{
	CCNode* root;
	CCNode* target;
	MotionStreak* streak;
}
@end


