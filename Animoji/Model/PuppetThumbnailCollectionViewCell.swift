//
//  PuppetThumbnailCollectionViewCell.swift
//  Animoji
//
//  Created by Daniel Illescas Romero on 25/12/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

@objc class PuppetThumbnailCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate {
	
	var thumbnailImageView = UIImageView()
	var selectionImageView = UIImageView()
	
	override init(frame: CGRect) {
		super.init(frame: CGRect.zero)
		self.setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupView() {
		
		self.backgroundColor = .white
		
		self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
		self.thumbnailImageView.contentMode = .scaleAspectFit
		self.contentView.addSubview(self.thumbnailImageView)
		
		self.selectionImageView.image = #imageLiteral(resourceName: "selection")
		self.selectionImageView.translatesAutoresizingMaskIntoConstraints = false
		self.selectionImageView.isHidden = true
		self.contentView.addSubview(self.selectionImageView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let thumbnailMargins = UIEdgeInsetsMake(7, 7, 7, 7)
		self.thumbnailImageView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, thumbnailMargins)
		self.selectionImageView.frame = self.contentView.bounds
	}
	
	override var isSelected: Bool {
		didSet {
			self.selectionImageView.isHidden = !isSelected
		}
	}
}
