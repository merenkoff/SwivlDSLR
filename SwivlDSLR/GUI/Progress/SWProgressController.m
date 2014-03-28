//
//  SWProgressController.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/27/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWProgressController.h"

#import "SWScript.h"
#import "SWTimelapseSettings.h"

#import "SWProgressView.h"

@interface SWProgressController()
{
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIView *_progressViewContainer;

    SWProgressView *_progressView;
    NSTimer *_progressTimer;
}
@end

@implementation SWProgressController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _progressView = [[SWProgressView alloc] initWithFrame:self.view.bounds];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _progressView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:_progressView belowSubview:_timeLabel];
    
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)tick
{
    CGFloat timePast = [[NSDate date] timeIntervalSinceDate:self.script.startDate];
    
    CGFloat progress = timePast / self.script.timelapseSettings.recordingTime;
    if (progress > 1) {
        _timeLabel.hidden = YES;
        [_progressTimer invalidate];
        progress = 1;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AVSandboxScriptProgressDidFinishNotification
                                                            object:self
                                                          userInfo:@{@"script" : self.script}];
    }
    _progressView.progress = progress;
    
    CGFloat timeLeft = self.script.timelapseSettings.recordingTime - timePast;
    SWTimeComponents timeComps = SWTimeComponentsMake(timeLeft);
    _timeLabel.text = [NSString stringWithFormat:@"%.2li:%.2li:%.2li", (long)timeComps.hours, (long)timeComps.minutes, (long)timeComps.seconds];
}

#pragma mark -

- (void)dealloc
{
    [_progressTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end