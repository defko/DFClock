//
//  AnalogHourView.h
//  DefSpinner
//
//  Created by Kiss Tamas on 2013.06.17..
//  Copyright (c) 2013 defko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFClockView : UIView

/*---- Clock color properties -----*/
@property (nonatomic, strong) UIColor* circleColor;

/*---- Clock size properties -----*/
@property (nonatomic) double radius;
@property (nonatomic) CGFloat bigCircleWidth;
@property (nonatomic) CGFloat littleCircleWidth;
@property (nonatomic) CGFloat minuteWidth;
@property (nonatomic) CGFloat minuteLength;
@property (nonatomic) CGFloat hourWidth;
@property (nonatomic) CGFloat hourLength;
@property (nonatomic) CGFloat secondWidth;
@property (nonatomic) CGFloat secondLength;

/*---- Time properties -----*/
@property (nonatomic, strong) NSDate *time;
- (void) setTime:(NSDate *)time isAnimated:(BOOL) isAnimated;

@end
