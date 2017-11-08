//
//  YouTubeMerger.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 09/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit
import XCDYouTubeKit

public enum YouTubeMergerError: Error {
    case cannotRemoveExistingDownloadVideo(Error)
    case cannotFetchVideo(Error)
    case cannotDownloadVideo(Error)
    case videoURLUnavailable
    case cannotGetVideoTrackFromAnimojiVideos
    case cannotGetVideoTrackFromAnimojiVideo
    case cannotMergeVideoAndAudio(AnimojiAudioMergerError)
    case unknownError
}

@objc public class YouTubeMergerOperation: NSObject {
    fileprivate var youTubeOperation: XCDYouTubeOperation?
    fileprivate var downloadTask: URLSessionDownloadTask?
    fileprivate private(set) var isCancelled = false
    
    @objc public func cancel() {
        isCancelled = true
        youTubeOperation?.cancel()
        downloadTask?.cancel()
    }
}

@objc public class YouTubeMerger: NSObject {
    private let animojiAudioMerger = AnimojiAudioMerger()
    
    @objc public override init() {
        super.init()
    }
    
    @objc public func merge(animojiVideoURL: URL, videoId: String, startTime: CMTime, endTime: CMTime, exportURL: URL, success: @escaping (URL) -> Void, failure: @escaping (Error) -> Void) -> YouTubeMergerOperation {
        return downloadVideo(withId: videoId) { downloadVideoResult in
            switch downloadVideoResult {
            case .value(let youTubeVideoURL):
                self.animojiAudioMerger.merge(animojiVideoURL: animojiVideoURL, audioVideoURL: youTubeVideoURL, startTime: startTime, endTime: endTime, exportURL: exportURL, completion: { result in
                    switch result {
                    case .value(let exportURL):
                        success(exportURL)
                    case .error(let error):
                        failure(YouTubeMergerError.cannotMergeVideoAndAudio(error))
                    }
                })
            case .error(let error):
                failure(error)
            }
        }
    }
}

private extension YouTubeMerger {    
    private func downloadVideo(withId videoId: String, completion: @escaping (Result<URL, YouTubeMergerError>) -> Void) -> YouTubeMergerOperation {
        let mergerOperation = YouTubeMergerOperation()
        let youTubeOperation = XCDYouTubeClient.`default`().getVideoWithIdentifier(videoId) { video, error in
            if let video = video {
                let videoURL = video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                    ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]
                    ?? video.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                if let videoURL = videoURL {
                    DispatchQueue.global(qos: .userInitiated).async {
                        mergerOperation.downloadTask = self.downloadVideo(from: videoURL) { result in
                            if !mergerOperation.isCancelled {
                                DispatchQueue.main.async {
                                    completion(result)
                                }
                            }
                        }
                    }
                } else {
                    if !mergerOperation.isCancelled {
                        completion(.error(YouTubeMergerError.videoURLUnavailable))
                    }
                }
            } else if let error = error {
                if !mergerOperation.isCancelled {
                    completion(.error(YouTubeMergerError.cannotFetchVideo(error)))
                }
            } else {
                if !mergerOperation.isCancelled {
                    completion(.error(YouTubeMergerError.unknownError))
                }
            }
        }
        mergerOperation.youTubeOperation = youTubeOperation
        return mergerOperation
    }
    
    private func downloadVideo(from remoteURL: URL, completion: @escaping (Result<URL, YouTubeMergerError>) -> Void) -> URLSessionDownloadTask {
        do {
            try self.removeExistingDownloadedVideoIfNecessary()
        } catch {
            completion(.error(YouTubeMergerError.cannotRemoveExistingDownloadVideo(error)))
        }
        let task = URLSession.shared.downloadTask(with: remoteURL) { tmpDownloadURL, responses, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(YouTubeMergerError.cannotDownloadVideo(error)))
                }
            } else if let tmpDownloadURL = tmpDownloadURL {
                do {
                    let localURL = self.downloadedVideoURL()
                    try FileManager.`default`.copyItem(at: tmpDownloadURL, to: localURL)
                    DispatchQueue.main.async {
                        completion(.value(localURL))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.error(YouTubeMergerError.unknownError))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.error(YouTubeMergerError.unknownError))
                }
            }
        }
        task.resume()
        return task
    }
    
    private func removeExistingDownloadedVideoIfNecessary() throws {
        let videoURL = downloadedVideoURL()
        let fileManager = FileManager.`default`
        if fileManager.fileExists(atPath: videoURL.path, isDirectory: nil) {
            try fileManager.removeItem(at: videoURL)
        }
    }
    
    private func downloadedVideoURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("yttemp.mp4")
    }
}
