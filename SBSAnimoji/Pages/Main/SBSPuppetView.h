//
//  SBSPuppetView.h
//  SBSAnimoji
//
//  Created by Simon Støvring on 06/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "AVTPuppetView.h"

@class SBSPuppetView;

@protocol SBSPuppetViewDelegate <NSObject>
- (void)puppetViewDidFinishPlaying:(SBSPuppetView *)puppetView;
- (void)puppetViewDidStartRecording:(SBSPuppetView *)puppetView;
- (void)puppetViewDidStopRecording:(SBSPuppetView *)puppetView;
@end

@interface SBSPuppetView : AVTPuppetView
@property (nonatomic, weak) id<SBSPuppetViewDelegate> sbsDelegate;
@end
