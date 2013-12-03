//
//  AnalogHourView.m
//  DefSpinner
//
//  Created by Kiss Tamas on 2013.06.17..
//  Copyright (c) 2013 defko. All rights reserved.
//

#import "DFClockView.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface DFClockView()
{
    CGFloat _hourAngle;
    CGFloat _minuteAngle;
    CGFloat _secondAngle;
    
    CGFloat _prevHourAngle;
    CGFloat _prevMinuteAngle;
    CGFloat _prevSecondAngle;
    BOOL _isAnimated;
    
    NSTimer *_animationTimer;
    CGContextRef _context;
    
    NSDate* _prevDate;
    BOOL _isDirectionForward;
}

@end

@implementation DFClockView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    _radius = self.frame.size.width - 5;
    _bigCircleWidth = 10.f;
    _littleCircleWidth = 15.f;
    _minuteWidth = 1.f;
    _minuteLength = _radius/2 - 3;
    _hourWidth = 2.f;
    _hourLength = _radius/4 + 1;
    _secondWidth = 1.f;
    _secondLength = _radius/2 - 3;
    _circleColor = [UIColor colorWithRed:(90.f/255.f) green:(51.f/255.f) blue:(65.f/255.f) alpha:1.0];
}

- (void) setTime:(NSDate *)time
{
    [self setTime:time isAnimated:NO];
}

- (void) setTime:(NSDate *)time isAnimated:(BOOL) isAnimated
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:time];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
   
    _hourAngle = [self angleAtHour:hour];
    _minuteAngle = [self angleAtMinute:minute];
    _secondAngle = [self angleAtMinute:second];
    _time = time;
    
    if (!_prevDate) {
        _prevDate = time;
        _prevHourAngle = _hourAngle;
        _prevMinuteAngle = _minuteAngle;
        _prevSecondAngle = _secondAngle;
    }
    _isAnimated = isAnimated;
    _isDirectionForward = [_prevDate compare:_time] == NSOrderedAscending;
    
    if (isAnimated) {
        NSTimer* animationTimer = [NSTimer timerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(moveAnimation:)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
    } else {
        [self setNeedsDisplay];
    }
}

- (void) moveAnimation:(NSTimer*) timer
{
    BOOL isAllDone = NO;
    BOOL isHourDone = NO;
    BOOL isMinuteDone = NO;
    BOOL isSecondDone = NO;
    
    if (_prevMinuteAngle != _minuteAngle) {
       _prevMinuteAngle = [self setPreviousAngle:_prevMinuteAngle];
        [self setNeedsDisplay];
    } else {
        isMinuteDone = YES;
    }
    
    if (_prevHourAngle != _hourAngle) {
       _prevHourAngle = [self setPreviousAngle:_hourAngle];
        [self setNeedsDisplay];
    } else {
        isHourDone = YES;
    }
  
    if (_prevSecondAngle != _secondAngle) {
        _prevSecondAngle = [self setPreviousAngle:_prevSecondAngle];
        [self setNeedsDisplay];
    } else {
        isSecondDone = YES;
    }
    

    if (isHourDone && isMinuteDone && isSecondDone) {
        isAllDone = YES;
    }
    
    if (isAllDone) {
        [timer invalidate];
        timer = nil;
        [_animationTimer invalidate];
        _animationTimer = nil;
        _prevMinuteAngle = _minuteAngle;
        _prevHourAngle = _hourAngle;
        _prevSecondAngle = _secondAngle;
        _prevDate = _time;
    }
}

- (CGFloat) setPreviousAngle:(CGFloat) prevAngle
{
    if (_isDirectionForward) {
        if (prevAngle >= 360) {
            prevAngle = -1;
        }
        prevAngle = prevAngle + 1;
    } else {
        if (prevAngle <= 0) {
            prevAngle = 361;
        }
        prevAngle = prevAngle - 1;
    }
    return prevAngle;
}

- (void)drawRect:(CGRect)rect
{
    if (!_time) {
        return;
    }
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _context = UIGraphicsGetCurrentContext();
    
    //Big circle
    CGContextSetStrokeColorWithColor(_context, _circleColor.CGColor);
    CGContextSetLineWidth(_context, _bigCircleWidth);
    CGRect bigCirlce = CGRectMake(centerPoint.x - _radius/2,centerPoint.y - _radius/2,_radius,_radius);
    CGContextAddEllipseInRect(_context, bigCirlce);
    CGContextStrokePath(_context);
    
    //Little circle    
    CGContextSetLineWidth(_context, 1.f);
    CGRect littleCirlce = CGRectMake(centerPoint.x - _littleCircleWidth/2,
                                     centerPoint.y - _littleCircleWidth/2,
                                     _littleCircleWidth,
                                     _littleCircleWidth);
    CGContextSetFillColorWithColor(_context, _circleColor.CGColor);
    CGContextFillEllipseInRect(_context, littleCirlce);
    CGContextStrokePath(_context);
    
    //Hour pointer
    CGContextSetLineWidth(_context, _hourWidth);
    CGContextSetStrokeColorWithColor(_context, _circleColor.CGColor);
    CGContextMoveToPoint(_context, centerPoint.x, centerPoint.y);
    CGPoint hourPoint = [self getPointWithAngle:[self getHourAngle] andRadius:_hourLength andCenterPoint:centerPoint];
    CGContextAddLineToPoint(_context, hourPoint.x, hourPoint.y);
    CGContextStrokePath(_context);

    //Minute pointer
    CGContextSetLineWidth(_context, _minuteWidth);
    CGContextSetStrokeColorWithColor(_context, _circleColor.CGColor);
    CGContextMoveToPoint(_context, centerPoint.x, centerPoint.y);
    CGPoint minutePoint = [self getPointWithAngle:[self getMinuteAngle] andRadius:_minuteLength andCenterPoint:centerPoint];
    CGContextAddLineToPoint(_context, minutePoint.x, minutePoint.y);
    CGContextStrokePath(_context);
    
    //Second pointer
    CGContextSetLineWidth(_context, _secondWidth);
    CGContextSetStrokeColorWithColor(_context, _circleColor.CGColor);
    CGContextMoveToPoint(_context, centerPoint.x, centerPoint.y);
    CGPoint secondPoint = [self getPointWithAngle:[self getSecondAngle] andRadius:_secondLength andCenterPoint:centerPoint];
    CGContextAddLineToPoint(_context, secondPoint.x, secondPoint.y);
    CGContextStrokePath(_context);
}

- (CGFloat) getSecondAngle
{
    CGFloat angle;
    if (_isAnimated) {
        angle = _prevSecondAngle;
    } else {
        angle = _secondAngle;
    }
    return angle;
}


- (CGFloat) getMinuteAngle
{
    if (_isAnimated) {
        return _prevMinuteAngle;
    } else {
        return _minuteAngle;
    }
}

- (CGFloat) getHourAngle
{
    if (_isAnimated) {
        return _prevHourAngle;
    } else {
        return _hourAngle;
    }
}

- (CGPoint) getPointWithAngle:(CGFloat) angle andRadius:(double) radius andCenterPoint:(CGPoint) centerPoint
{
    CGFloat sinAlfa = sinf(DEGREES_TO_RADIANS(angle));
    CGFloat c = sinAlfa * radius;
    CGFloat cosAlfa = cosf(DEGREES_TO_RADIANS(angle));
    CGFloat a = cosAlfa * radius;
    
    CGFloat x = centerPoint.x + c;
    CGFloat y = (centerPoint.y - a);

    return CGPointMake(x,y);
}

- (CGFloat) angleAtHour: (NSInteger) hour
{
    int hourIn12 = hour % 12;
    CGFloat oneHour = 360 / 12;
    CGFloat angle = hourIn12 * oneHour;
    return angle;
}

- (CGFloat) angleAtMinute: (NSInteger) minute
{
    CGFloat oneMinute = 360 / 60;
    CGFloat angle = minute * oneMinute;
    return angle;
}

@end
