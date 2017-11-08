//
//  AnimojiAudioMerger.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 09/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import Foundation
import AVFoundation

public enum AnimojiAudioMergerError: Error {
    case cannotInsertVideoTrackIntoComposition
    case cannotInsertAudioTrackIntoComposition
    case cannotGetVideoTrackFromAnimojiVideo
    case cannotGetAudioTrackFromAudioVideo
    case cannotInsertTimeRangeIntoComposition(Error)
    case cannotCreateExportSession
    case unknownError
}

class AnimojiAudioMerger {
    private let queue = DispatchQueue(label: "dk.simonbs.AnimojiAudioMerger", qos: .userInitiated)
    
    func merge(animojiVideoURL: URL, audioVideoURL: URL, startTime: CMTime, endTime: CMTime, exportURL: URL, completion: @escaping (Result<URL, AnimojiAudioMergerError>) -> Void) {
        queue.async {
            do {
                let mixComposition = try self.createComposition(
                    animojiVideoURL: animojiVideoURL,
                    audioVideoURL: audioVideoURL,
                    startTime: startTime,
                    endTime: endTime)
                try self.export(mixComposition, to: exportURL) {
                    DispatchQueue.main.async {
                        completion(.value(exportURL))
                    }
                }
            } catch let error as AnimojiAudioMergerError {
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.error(AnimojiAudioMergerError.unknownError))
                }
            }
        }
    }
}

private extension AnimojiAudioMerger {
    private func export(_ mixComposition: AVMutableComposition, to exportURL: URL, completion: @escaping () -> Void) throws {
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            throw AnimojiAudioMergerError.cannotCreateExportSession
        }
        exportSession.outputURL = exportURL
        exportSession.outputFileType = .mov
        exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
        exportSession.exportAsynchronously(completionHandler: completion)
    }
    
    private func createComposition(animojiVideoURL: URL, audioVideoURL: URL, startTime: CMTime, endTime: CMTime) throws -> AVMutableComposition {
        let audioVideoAsset = AVURLAsset(url: audioVideoURL)
        let animojiVideoAsset = AVURLAsset(url: animojiVideoURL)
        let mixComposition = AVMutableComposition()
        let _compositionVideoTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid)
        let _compositionAudioTrack = mixComposition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid)
        guard let compositionVideoTrack = _compositionVideoTrack else {
            throw AnimojiAudioMergerError.cannotInsertVideoTrackIntoComposition
        }
        guard let compositionAudioTrack = _compositionAudioTrack else {
            throw AnimojiAudioMergerError.cannotInsertAudioTrackIntoComposition
        }
        guard let animojiVideoTrack = animojiVideoAsset.tracks(withMediaType: .video).first else {
            throw AnimojiAudioMergerError.cannotGetVideoTrackFromAnimojiVideo
        }
        guard let audioTrack = audioVideoAsset.tracks(withMediaType: .audio).first else {
            throw AnimojiAudioMergerError.cannotGetAudioTrackFromAudioVideo
        }
        // Insert video and audio
        let animojiVideoTimeRange = CMTimeRange(start: kCMTimeZero, duration: animojiVideoAsset.duration)
        let audioTimeRange = CMTimeRange(start: startTime, end: endTime)
        do {
            // Insert video
            try compositionVideoTrack.insertTimeRange(animojiVideoTimeRange, of: animojiVideoTrack, at: kCMTimeZero)
        } catch {
            throw AnimojiAudioMergerError.cannotInsertTimeRangeIntoComposition(error)
        }
        do {
            // Insert audio
            try compositionAudioTrack.insertTimeRange(audioTimeRange, of: audioTrack, at: kCMTimeZero)
        } catch {
            throw AnimojiAudioMergerError.cannotInsertTimeRangeIntoComposition(error)
        }
        return mixComposition
    }
}
