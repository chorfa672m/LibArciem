/*******************************************************************************
 
 Copyright 2011 Arciem LLC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 *******************************************************************************/

#import "CNavigationBar.h"
#import "UIViewUtils.h"

@interface CNavigationBar ()

@property(nonatomic) CGPoint lastPointInsidePoint;
@property(nonatomic) NSTimeInterval lastPointInsideTimestamp;

@end

@implementation CNavigationBar

@synthesize backgroundImage = backgroundImage_;

@synthesize ignoreSlopRegion = ignoreSlopRegion_;
@synthesize lastPointInsidePoint = lastPointInsidePoint_;
@synthesize lastPointInsideTimestamp = lastPointInsideTimestamp_;

- (void)drawRect:(CGRect)rect 
{
	if (self.backgroundImage != nil) {
		CGRect r = self.bounds;
		[self.backgroundImage drawInRect:CGRectMake(0, 0, r.size.width, r.size.height)];
	} else {
		[super drawRect:rect];
	}
} 

- (void)dealloc
{
	self.backgroundImage = nil;
	[super dealloc];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	BOOL result = [super pointInside:point withEvent:event];

	// The Navigation Bar has a slop region extending several pixels below it. The OS creates this slop region by generating a hit test with an artificially low Y coordinate and does this immediately after a couple hit tests with a normal Y coordinate. This code causes the artificial hit test to fail, nullifying the slop region.
	if(self.ignoreSlopRegion) {
		NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
		
		if(result == YES) {
			NSTimeInterval elapsed = currentTime - self.lastPointInsideTimestamp;
//			CLogDebug(nil, @"elapsed:%f", elapsed);
			if(elapsed < 0.01) {
				if(point.y < self.lastPointInsidePoint.y) {
					result = NO;
				}
			}
		}
//		CLogDebug(nil, @"%@ pointInside:%@ withEvent:%@ result:%d", self, NSStringFromCGPoint(point), event, result);
		
		self.lastPointInsidePoint = point;
		self.lastPointInsideTimestamp = currentTime;
	}

	return result;
}

@end
