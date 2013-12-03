//
//  DFClockViewController.m
//  DFClock
//
//  Created by Kiss Tamas on 2013.12.03..
//  Copyright (c) 2013 defko. All rights reserved.
//

#import "DFClockViewController.h"
#import "DFClockView.h"

@interface DFClockViewController ()
{
    NSTimer *_timer;
}

@end

@implementation DFClockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dfClock.time = [NSDate date];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTimeToClock) userInfo:nil repeats:YES];
}

- (void) setTimeToClock
{
    [self.dfClock setTime:[NSDate date] isAnimated:YES];
}

@end
