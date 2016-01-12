//
// BKCircularSwitch.m
//
// Copyright (c) 2016 Bogdan Kovachev (http://1337.bg)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "BKCircularSwitch.h"

#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)
#define radiansToDegrees(radians) ((radians) * (180.0 / M_PI))

@interface BKCircularSwitch () {
    // User interface
    UIImageView *imageView;

    // Other
    CGPoint center;
    CGPoint prevPoint;
    CGFloat angle;
    BOOL isInterfaceBuilder;
}

@end

@implementation BKCircularSwitch

#pragma mark - Life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createUserInterface];
    }

    return self;
}

// The Interface Builder use only this initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUserInterface];
    }

    return self;
}

// Only Interface Builder call this method
- (void)prepareForInterfaceBuilder {
    isInterfaceBuilder = YES;
}

- (void)awakeFromNib {
    // Interface Builder doesn't call this method, so the check is not needed
    [self addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)drawRect:(CGRect)rect {
    // Call super's drawRect method because we subclass UIControl instead of UIView
    [super drawRect:rect];

    imageView.frame = rect;
    imageView.image = self.backgroundImage;

    center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (void)dealloc {
    // Interface Builder preview crash if we're trying to use KVO
    if (!isInterfaceBuilder) {
        [self removeObserver:self forKeyPath:@"value"];
    }
}

#pragma mark - Actions

- (void)createUserInterface {
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:imageView];
}

// Returns the angle between two points in radians
- (CGFloat)angleBetweenPointA:(CGPoint)initialPosition andPointB:(CGPoint)currentPosition center:(CGPoint)origin {
    CGFloat initialAngle = atan2f(initialPosition.y - origin.y, initialPosition.x - origin.x);
    CGFloat currentAngle = atan2f(currentPosition.y - origin.y, currentPosition.x - origin.x);

    if (currentAngle < initialAngle) {
        currentAngle += 2 * M_PI;
    }

    return currentAngle - initialAngle;
}

#pragma mark - Touch related actions

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];

    prevPoint = [touch locationInView:self];

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];

    CGPoint lastPoint = [touch locationInView:self];

    CGFloat lastAngle = [self angleBetweenPointA:prevPoint andPointB:lastPoint center:center];

    if (lastAngle > M_PI_2) {
        angle -= 2 * M_PI - lastAngle;
    } else {
        angle += lastAngle;
    }

    prevPoint = lastPoint;

    self.value = @(floorf(radiansToDegrees(angle)));

    [self sendActionsForControlEvents:UIControlEventValueChanged];

    return YES;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"value"]) {
        angle = degreesToRadians(self.value.integerValue);

        imageView.transform = CGAffineTransformMakeRotation(angle);
    }
}

@end