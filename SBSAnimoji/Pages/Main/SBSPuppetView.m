//
//  SBSPuppetView.m
//  SBSAnimoji
//
//  Created by Simon Støvring on 06/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "SBSPuppetView.h"

@implementation SBSPuppetView

- (void)audioPlayerItemDidReachEnd:(id)arg1 {
    [super audioPlayerItemDidReachEnd:arg1];
    if ([self.sbsDelegate respondsToSelector:@selector(puppetViewDidFinishPlaying:)]) {
        [self.sbsDelegate puppetViewDidFinishPlaying:self];
    }
}

- (void)startRecording {
    [super startRecording];
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
