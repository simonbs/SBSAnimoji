//
//  YouTubeSearchResultTableViewCell.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 08/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit

class YouTubeSearchResultTableViewCell: UITableViewCell {
    let videoNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        contentView.addSubview(videoNameLabel)
    }
    
    private func setupLayout() {
        videoNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        videoNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        videoNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        videoNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
}

