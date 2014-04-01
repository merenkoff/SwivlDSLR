//
//  SWScript.m
//  SwivlDSLR
//
//  Created by Zhenya Koval on 3/20/14.
//  Copyright (c) 2014 Swivl. All rights reserved.
//

#import "SWScript.h"

#import "SWTimelapseSettings.h"

@implementation SWScript

#pragma mark - Init

- (instancetype)initWithTimelapseSettings:(SWTimelapseSettings *)timelapseSettings
{
    self = [super init];
    if (self) {
        _timelapseSettings = timelapseSettings;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self) {
        _startDate = [decoder decodeObjectForKey:@"startDate"];
        _timelapseSettings = [decoder decodeObjectForKey:@"timelapseSettings"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_startDate forKey:@"startDate"];
    [encoder encodeObject:_timelapseSettings forKey:@"timelapseSettings"];
}

#pragma mark - Public methods

- (NSString *)generateScript
{
    NSString *scriptStr;
    if (self.type == SWCameraInterfaceUSB) {
        scriptStr = [self generateScriptForUSB];
    } else if (self.type == SWCameraInterfaceTrigger) {
        scriptStr = [self generateScriptForTrigger];
    } else {
        NSAssert(NO, @"Invalid script type");
    }
    
    return [scriptStr stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)isRunningFromStartDate
{
    if (!self.startDate) {
        return YES;
    }
    
    CGFloat timePast = [[NSDate date] timeIntervalSinceDate:self.startDate];
    return timePast < self.timelapseSettings.recordingTime;
}

- (NSString *)generateScriptForTrigger
{
    NSInteger holdShutterTime = 2000;
    NSInteger protectionPause = 500;
    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000 - holdShutterTime - protectionPause;
    if (timeBtwPictures < 0) {
        timeBtwPictures = 0;
    }
    
    NSInteger stepSize = (self.timelapseSettings.stepSize / 0.11) * 4;
    NSInteger speed = 2000; //MAX
    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";
    
    NSString *script = [NSString stringWithFormat:
                        @"1:%lx, 1M %lx, 2M %lx, 3M %lx, 4M F(      \
                        2:T4L+9M 0, %lx, %lx%@, 5, 0, AR            \
                        3:AL3=                                      \
                        4:T9L-4< F( 1L1-,5= 1M2@                    \
                        5:.                                         \
                        F:FM 7S T2L+EM                              \
                        E:TEL-E< 3S T3L+EM                          \
                        D:TEL-D< FL)\0",
                        (long)self.timelapseSettings.stepCount,
                        (long)holdShutterTime,
                        (long)protectionPause,
                        (long)timeBtwPictures,
                        (long)speed,
                        (long)stepSize,
                        direction];
    
    return script;

}

- (NSString *)generateScriptForUSB
{

//    NSInteger timeBtwPictures = self.timelapseSettings.timeBetweenPictures * 1000;
//    NSInteger stepSize = (self.timelapseSettings.stepSize / 0.11) * 4;
//    NSString *direction = self.timelapseSettings.clockwiseDirection ? @"" : @"%";
//    NSInteger speed = 2000; //MAX
//
//    NSString *script = [NSString stringWithFormat:
//                        @"1:%lx, 1M %lx, 2M T2L+9M F(           \
//                        2:0, %lx, %lx%@, 5, 0, AR               \
//                        3:AL3=                                  \
//                        4:T9L-4< T2L+9M F( 1L1-, 5= 1M2@        \
//                        5:.                                     \
//                        ;PTP shutter                            \
//                        F:FM                                    \
//                        D:3, 0, B9128P2019?D=2001-E#3, A9129P   \
//                        E:FL)\0",
//                        
//                        (long)self.timelapseSettings.stepCount,
//                        (long)timeBtwPictures,
//                        (long)speed,
//                        (long)stepSize,
//                        direction];
    
    NSString *script =  @"                                  \
                        1:3,1M 2710,2M T2L+9M F(            \
                        2:2710,320,7D0,5,0,AR               \
                        3:AL3=                              \
                        4:T9L-4< T2L+9M F( 1L1-,5= 1M2@     \
                        5:.                                 \
                        F:FM                                \
                        D:3,0,B9128P2019?D=2001-E#3,A9129P  \
                        E:FL)\0";
    
    return script;
}

@end
