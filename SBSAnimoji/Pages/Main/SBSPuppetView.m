//
//  SBSPuppetView.m
//  SBSAnimoji
//
//  Created by Simon Støvring on 06/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "SBSPuppetView.h"
#import <objc/runtime.h>

#define MAX_RECORDING_DURATION 60 // Seconds

@implementation SBSPuppetView

- (void)audioPlayerItemDidReachEnd:(id)arg1 {
    [super audioPlayerItemDidReachEnd:arg1];
    if ([self.sbsDelegate respondsToSelector:@selector(puppetViewDidFinishPlaying:)]) {
        [self.sbsDelegate puppetViewDidFinishPlaying:self];
    }
}

- (void)startRecording {
    [super startRecording];
    
    int duration = MAX_RECORDING_DURATION * 60;
    
    NSMutableData *timesBuffer = [NSMutableData dataWithCapacity: duration * 8];
    NSMutableData *blendShapeBuffer = [NSMutableData dataWithCapacity: duration * 204];
    NSMutableData *transformData = [NSMutableData dataWithCapacity: duration * 64];
    
    [self setValue:[NSNumber numberWithInt:duration] forKey:@"_recordingCapacity"];
    [self setValue:timesBuffer forKey:@"_rawTimesData"];
    [self setValue:blendShapeBuffer forKey:@"_rawBlendShapesData"];
    [self setValue:transformData forKey:@"_rawTransformsData"];
    
    {
        Ivar ivar = class_getInstanceVariable([AVTRecordView class], "_rawTimes");
        object_setIvar(self, ivar, [timesBuffer mutableBytes]);
    }
    
    {
        Ivar ivar = class_getInstanceVariable([AVTRecordView class], "_rawBlendShapes");
        object_setIvar(self, ivar, [blendShapeBuffer mutableBytes]);
    }
    
    {
        Ivar ivar = class_getInstanceVariable([AVTRecordView class], "_rawTransforms");
        object_setIvar(self, ivar, [transformData mutableBytes]);
    }
    
    if ([self.sbsDelegate respondsToSelector:@selector(puppetViewDidStartRecording:)]) {
        [self.sbsDelegate puppetViewDidStartRecording:self];
    }
}

- (void)stopRecording {
    [super stopRecording];
    if ([self.sbsDelegate respondsToSelector:@selector(puppetViewDidStopRecording:)]) {
        [self.sbsDelegate puppetViewDidStopRecording:self];
    }
}

@end
