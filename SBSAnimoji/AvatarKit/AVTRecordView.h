/* Generated by RuntimeBrowser
   Image: /System/Library/PrivateFrameworks/AvatarKit.framework/AvatarKit
 */

@import Foundation;
#import "AVTView.h"

@interface AVTRecordView: AVTView
@property (getter=isPreviewing, nonatomic, readonly) bool previewing;
@property (getter=isRecording, nonatomic, readonly) bool recording;
- (void)audioPlayerItemDidReachEnd:(id)arg1;
- (bool)exportMovieToURL:(id)arg1 options:(id)arg2 completionHandler:(id /* block */)arg3;
- (double)recordingDuration;
- (void)startPreviewing;
- (void)startRecording;
- (void)stopPreviewing;
- (void)stopRecording;
@end
