//
//  YouTubePlayerView.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 09/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit
import AVKit

class PlayerContainerView: UIView {
    let playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspect
        return layer
    }()
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

class YouTubePlayerView: UIView {
    let playerContainerView: PlayerContainerView = {
        let view = PlayerContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let controlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        return stackView
    }()
    let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(sbs_imageNamed: "youtube-play"), for: .normal)
        button.tintColor = .black
        button.isEnabled = false
        return button
    }()
    let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(sbs_imageNamed: "youtube-forward"), for: .normal)
        button.tintColor = .black
        button.isEnabled = false
        return button
    }()
    let rewindButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(sbs_imageNamed: "youtube-rewind"), for: .normal)
        button.tintColor = .black
        button.isEnabled = false
        return button
    }()
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(sbs_imageNamed: "youtube-close"), for: .normal)
        return button
    }()
    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = .white
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        playerContainerView.backgroundColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1)
        controlsContainerView.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1)
        controlsStackView.addArrangedSubview(forwardButton)
        controlsStackView.addArrangedSubview(playPauseButton)
        controlsStackView.addArrangedSubview(rewindButton)
        controlsContainerView.addSubview(controlsStackView)        
        contentView.addSubview(controlsContainerView)
        contentView.addSubview(playerContainerView)
        contentView.addSubview(activityIndicatorView)
        addSubview(contentView)
        addSubview(closeButton)
    }
    
    private func setupLayout() {
        playerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        playerContainerView.trailingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor).isActive = true
        playerContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor).isActive = true
        playerContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        playerContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9/16).isActive = true
        playerContainerView.widthAnchor.constraint(equalToConstant: 224).isActive = true
        
        controlsStackView.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor).isActive = true
        controlsStackView.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor).isActive = true
        controlsStackView.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 5).isActive = true
        controlsStackView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor).isActive = true
        
        controlsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        controlsContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        controlsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        controlsContainerView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor).isActive = true
        
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func addPlayerView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        playerContainerView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: playerContainerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor).isActive = true
    }
}

