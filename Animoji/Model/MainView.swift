//
//  MainView.swift
//  Animoji
//
//  Created by Daniel Illescas Romero on 25/12/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

@objc class MainView: UIView {
	
	var puppetView = SBSPuppetView()
	var thumbnailsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
	var recordButton = UIButton(type: .system)
	var shareButton = UIButton(type: .system)
	var deleteButton = UIButton(type: .system)
	var previewButton = UIButton(type: .system)
	var activityIndicatorView = UIActivityIndicatorView()
	var durationLabel = UILabel()
	var puppetViewSeparatorView = UIView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
		self.setupLayout()
	}
	
	func setupView() {

		self.backgroundColor = .white
		
		self.puppetView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.puppetView)
		
		self.puppetViewSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		self.puppetViewSeparatorView.backgroundColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
		self.addSubview(self.puppetViewSeparatorView)
		
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.scrollDirection = .vertical
		collectionViewLayout.minimumInteritemSpacing = 14
		collectionViewLayout.minimumLineSpacing = 10
		
		self.thumbnailsCollectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
		self.thumbnailsCollectionView.translatesAutoresizingMaskIntoConstraints = false
		self.thumbnailsCollectionView.backgroundColor = .white
		self.thumbnailsCollectionView.contentInset = UIEdgeInsets(top: 15, left: 7, bottom: 15, right: 7)
		self.thumbnailsCollectionView.showsHorizontalScrollIndicator = false
		self.addSubview(self.thumbnailsCollectionView)
		
		self.durationLabel.translatesAutoresizingMaskIntoConstraints = false
		self.durationLabel.textAlignment = .right
		self.durationLabel.font = .systemFont(ofSize: 14, weight: .medium)
		self.durationLabel.isHidden = true
		self.addSubview(self.durationLabel)
		
		self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
		self.deleteButton.isHidden = true
		self.deleteButton.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
		self.addSubview(self.deleteButton)
		
		self.previewButton.translatesAutoresizingMaskIntoConstraints = false
		self.previewButton.isHidden = true
		self.previewButton.setImage(#imageLiteral(resourceName: "start-previewing"), for: .normal)
		self.addSubview(self.previewButton)
		
		self.recordButton.translatesAutoresizingMaskIntoConstraints = false
		self.recordButton.setImage(#imageLiteral(resourceName: "start-recording"), for: .normal)
		self.addSubview(self.recordButton)
		
		self.shareButton.translatesAutoresizingMaskIntoConstraints = false
		self.shareButton.isHidden = true
		self.shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
		self.addSubview(self.shareButton)
		
		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		self.activityIndicatorView.hidesWhenStopped = true
		self.addSubview(self.activityIndicatorView)
	}
	
	func setupLayout() {
		
		self.puppetView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.puppetView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		self.puppetView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
		self.puppetView.heightAnchor.constraint(equalToConstant: 355).isActive = true
		
		self.puppetViewSeparatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.puppetViewSeparatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		self.puppetViewSeparatorView.topAnchor.constraint(equalTo: self.puppetView.bottomAnchor).isActive = true
		self.puppetViewSeparatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
		
		self.thumbnailsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		self.thumbnailsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		self.thumbnailsCollectionView.topAnchor.constraint(equalTo: self.puppetViewSeparatorView.bottomAnchor).isActive = true
		self.thumbnailsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		self.durationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		self.durationLabel.topAnchor.constraint(equalTo: self.puppetView.topAnchor, constant: 15).isActive = true
		
		self.recordButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		self.recordButton.bottomAnchor.constraint(equalTo: self.puppetView.bottomAnchor, constant: -20).isActive = true
		
		self.shareButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		self.shareButton.bottomAnchor.constraint(equalTo: self.puppetView.bottomAnchor, constant: -20).isActive = true
		
		self.deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		self.deleteButton.topAnchor.constraint(equalTo: self.puppetView.topAnchor, constant: 15).isActive = true
		
		self.previewButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
		self.previewButton.topAnchor.constraint(equalTo: self.deleteButton.bottomAnchor, constant: 15).isActive = true
		
		self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.shareButton.centerXAnchor).isActive = true
		self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.shareButton.centerYAnchor).isActive = true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let itemsPerRow: CGFloat = 4
		let collectionView = self.thumbnailsCollectionView
		let contentInset = collectionView.contentInset
		
		if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			let availableWidth = self.bounds.size.width - contentInset.left - contentInset.right - (itemsPerRow - 1) * flowLayout.minimumInteritemSpacing
			let itemLength = floor(availableWidth / itemsPerRow)
			flowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
