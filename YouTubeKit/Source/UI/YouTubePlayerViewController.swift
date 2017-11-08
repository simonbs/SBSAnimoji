//
//  YouTubePlayerViewController.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 09/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation

@objc public protocol YouTubePlayerViewControllerDelegate {
    func youTubePlayerViewController(_ youTubePlayerViewController: YouTubePlayerViewController, didLoadVideoWithId videoId: String)
    func youTubePlayerViewControllerDidFinish(_ youTubePlayerViewController: YouTubePlayerViewController)
    func youTubePlayerViewControllerDidClose(_ youTubePlayerViewController: YouTubePlayerViewController)
}

public class YouTubePlayerViewController: UIViewController {
    @objc public weak var delegate: YouTubePlayerViewControllerDelegate?
    @objc public var currentTime: CMTime {
        return player.currentTime()
    }
    
    private var player = AVPlayer()
    private var isLoadingVideo = false
    private var currentYouTubeOperation: XCDYouTubeOperation?
    private var contentView: YouTubePlayerView {
        return view as! YouTubePlayerView
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.`default`.addObserver(self, selector:#selector(didPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.`default`.removeObserver(self)
    }
    
    override public func loadView() {
        view = YouTubePlayerView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        contentView.playerContainerView.playerLayer.player = player
        contentView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        contentView.rewindButton.addTarget(self, action: #selector(rewindButtonPressed), for: .touchUpInside)
        contentView.forwardButton.addTarget(self, action: #selector(forwardButtonPressed), for: .touchUpInside)
        contentView.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    @objc public func removeVideo() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        contentView.playPauseButton.isEnabled = false
        contentView.rewindButton.isEnabled = false
        contentView.forwardButton.isEnabled = false
        contentView.playPauseButton.setImage(UIImage(sbs_imageNamed: "youtube-play"), for: .normal)
    }
    
    @objc public func showVideo(withId videoId: String) {
        isLoadingVideo = true
        removeVideo()
        contentView.activityIndicatorView.startAnimating()
        contentView.playPauseButton.isEnabled = false
        contentView.rewindButton.isEnabled = false
        contentView.forwardButton.isEnabled = false
        currentYouTubeOperation?.cancel()
        currentYouTubeOperation = XCDYouTubeClient.`default`().getVideoWithIdentifier(videoId) { [weak self] video, error in
            let _videoURL = video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                ?? video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]
                ?? video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
            guard let strongSelf = self, let videoURL = _videoURL else { return }
            let playerItem = AVPlayerItem(url: videoURL)
            strongSelf.player.replaceCurrentItem(with: playerItem)
            strongSelf.isLoadingVideo = false
            strongSelf.contentView.playPauseButton.isEnabled = true
            strongSelf.contentView.rewindButton.isEnabled = true
            strongSelf.contentView.forwardButton.isEnabled = true
            strongSelf.contentView.activityIndicatorView.stopAnimating()
            strongSelf.delegate?.youTubePlayerViewController(strongSelf, didLoadVideoWithId: videoId)
        }
    }
    
    @objc public func showControls() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.closeButton.alpha = 1
            self.contentView.playerContainerView.transform = .identity
        }
    }
    
    @objc public func hideControls() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.closeButton.alpha = 0
            self.contentView.playerContainerView.transform = CGAffineTransform(
                translationX: self.contentView.controlsContainerView.frame.width,
                y: 0)
        }
    }
    
    @objc public func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    @objc public func play() {
        player.play()
        contentView.playPauseButton.setImage(UIImage(sbs_imageNamed: "youtube-pause"), for: .normal)
        contentView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
    }
    
    @objc public func pause() {
        player.pause()
        contentView.playPauseButton.setImage(UIImage(sbs_imageNamed: "youtube-play"), for: .normal)
        contentView.playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
    }
}

private extension YouTubePlayerViewController {
    @objc private func playPauseButtonPressed() {
        if player.rate > 0 {
            pause()
        } else {
            play()
        }
    }
    
    @objc private func rewindButtonPressed() {
        let currentTime = player.currentTime()
        let preferredNewTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        let newTime = CMTimeMaximum(preferredNewTime, kCMTimeZero)
        player.seek(to: newTime)
    }
    
    @objc private func forwardButtonPressed() {
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = player.currentTime()
        let preferredNewTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        let newTime = CMTimeMinimum(preferredNewTime, duration)
        player.seek(to: newTime)
    }
    
    @objc private func closeButtonPressed() {        
        delegate?.youTubePlayerViewControllerDidClose(self)
    }
    
    @objc private func didPlayToEndTime() {
        contentView.playPauseButton.isEnabled = !isLoadingVideo
        contentView.rewindButton.isEnabled = !isLoadingVideo
        contentView.forwardButton.isEnabled = !isLoadingVideo
        player.seek(to: kCMTimeZero)
        delegate?.youTubePlayerViewControllerDidFinish(self)
    }
}
