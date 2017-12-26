//
//  ViewController.swift
//  Animoji
//
//  Created by Daniel Illescas Romero on 25/12/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

@objc class ViewController: UIViewController, SBSPuppetViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	
	var puppetNames = AVTPuppet.puppetNames() as? [String]
	
	var contentView: MainView? {
		return self.view as? MainView
	}
	
	var movieURL: URL? {
		let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
		return documentURL?.appendingPathComponent("animoji.mov")
	}
	
	var hasExportedMovie = Bool()
	var isExporting = Bool()
	var durationTimer = Timer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Animoji"
		self.view = MainView()
		
		self.contentView?.puppetView.sbsDelegate = self

		self.contentView?.thumbnailsCollectionView.dataSource = self
		self.contentView?.thumbnailsCollectionView.delegate = self
		self.contentView?.thumbnailsCollectionView.register(PuppetThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: "thumbnail")

		self.contentView?.recordButton.addTarget(self, action: #selector(self.toggleRecording), for: .touchUpInside)
		self.contentView?.deleteButton.addTarget(self, action: #selector(self.removeRecording), for: .touchUpInside)
		self.contentView?.previewButton.addTarget(self, action: #selector(self.startPreview), for: .touchUpInside)
		self.contentView?.shareButton.addTarget(self, action: #selector(self.share), for: .touchUpInside)
		
		if let name = self.puppetNames?[0] {
			self.showPuppetName(puppetName: name)
		}
		self.contentView?.thumbnailsCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: [])
	}

	deinit {
		self.contentView?.puppetView.removeObserver(self, forKeyPath: "recording")
	}
	
	@objc func durationTimerTriggered() {
		let recordingDuration = ceil(self.contentView?.puppetView.recordingDuration() ?? 0.0)
		let minutes = floor(recordingDuration / 60);
		let seconds = recordingDuration.truncatingRemainder(dividingBy: 60);
		self.contentView?.durationLabel.text = "\(minutes):\(seconds)"
	}
	
	func removeExistingMovieFile() {
		let fileManager = FileManager.default
		if let movieURL = self.movieURL, fileManager.fileExists(atPath: movieURL.path) {
			try? fileManager.removeItem(at: movieURL)
		}
	}
	
	// MARK: SBSPuppetViewDelegate
	
	public func puppetViewDidFinishPlaying(puppetView: SBSPuppetView) {
		if !puppetView.recording {
			self.stopPreview()
		}
	}
	
	public func puppetViewDidStartRecording(puppetView: SBSPuppetView) {
		self.hasExportedMovie = false
		self.removeExistingMovieFile()
		self.contentView?.recordButton.setImage(#imageLiteral(resourceName: "stop-recording"), for: .normal)
		self.contentView?.durationLabel.text = "00:00"
		self.contentView?.durationLabel.isHidden = false
		
		self.durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.durationTimerTriggered), userInfo: nil, repeats: true)
		
		self.contentView?.thumbnailsCollectionView.isUserInteractionEnabled = false
		
		UIView.animate(withDuration: 0.3, animations: {
			self.contentView?.thumbnailsCollectionView.alpha = 0.5
		})
	}
	
	public func puppetViewDidStopRecording(puppetView: SBSPuppetView) {
		if self.isExporting { return }
		self.durationTimer.invalidate()
		self.contentView?.recordButton.isHidden = true
		self.contentView?.shareButton.isHidden = false
		self.contentView?.deleteButton.isHidden = false
		self.contentView?.previewButton.isHidden = false
		self.contentView?.durationLabel.isHidden = true
		self.contentView?.recordButton.setImage(#imageLiteral(resourceName: "start-recording"), for: .normal)
		self.contentView?.thumbnailsCollectionView.isUserInteractionEnabled = true
		
		UIView.animate(withDuration: 0.3, animations: {
			self.contentView?.thumbnailsCollectionView.alpha = 1
		})
		self.startPreview()
	}
	
	// MARK: UICollectionViewDataSource
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.puppetNames?.count ?? 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnail", for: indexPath) as? PuppetThumbnailCollectionViewCell {
			if let name = self.puppetNames?[indexPath.item] {
				cell.thumbnailImageView.image = AVTPuppet.thumbnail(forPuppetNamed: name, options: nil)
				return cell
			}
		}
		return UICollectionViewCell()
	}
	
	// MARK: UICollectionViewDelegate
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let name = self.puppetNames?[indexPath.item] {
			self.showPuppetName(puppetName: name)
		}
	}
	
	// MARK: Convenience

	@objc private func share() {
		self.exportMovieIfNecessary { [unowned self] movieURL in
			let activityViewController = UIActivityViewController(activityItems: [movieURL], applicationActivities: nil)
			self.present(activityViewController, animated: true)
		}
	}
	
	private func exportMovieIfNecessary(completion: @escaping (URL) -> ()) {
		
		guard let movieURL = self.movieURL else { return }
		
		if self.hasExportedMovie {
			completion(movieURL)
		} else {
			self.isExporting = true
			self.contentView?.activityIndicatorView.startAnimating()
			self.contentView?.deleteButton.isEnabled = false
			self.contentView?.shareButton.isHidden = true
			
			self.contentView?.puppetView.exportMovie(toURL: movieURL, options: nil, completionHandler: { [unowned self] in
				self.hasExportedMovie = true
				self.contentView?.activityIndicatorView.stopAnimating()
				self.contentView?.deleteButton.isEnabled = true
				self.contentView?.shareButton.isHidden = false
				self.isExporting = false
				completion(movieURL)
			})
		}
	}
	
	@objc private func removeRecording() {
		self.hasExportedMovie = false
		self.removeExistingMovieFile()
		self.contentView?.puppetView.stopRecording()
		self.contentView?.puppetView.stopPreviewing()
		self.contentView?.recordButton.isHidden = false
		self.contentView?.deleteButton.isHidden = true
		self.contentView?.previewButton.isHidden = true
		self.contentView?.shareButton.isHidden = true
	}
	
	@objc private func toggleRecording() {
		if self.contentView?.puppetView.recording == true {
			self.contentView?.puppetView.stopRecording()
		} else {
			self.contentView?.puppetView.startRecording()
		}
	}
	
	@objc private func startPreview() {
		self.contentView?.previewButton.removeTarget(self, action: #selector(self.startPreview), for: .touchUpInside)
		self.contentView?.previewButton.addTarget(self, action: #selector(self.stopPreview), for: .touchUpInside)
		self.contentView?.previewButton.setImage(#imageLiteral(resourceName: "stop-previewing"), for: .normal)
		self.contentView?.puppetView.stopPreviewing()
		self.contentView?.puppetView.startPreviewing()
	}
	
	@objc private func stopPreview() {
		self.contentView?.previewButton.removeTarget(self, action: #selector(self.stopPreview), for: .touchUpInside)
		self.contentView?.previewButton.addTarget(self, action: #selector(self.startPreview), for: .touchUpInside)
		self.contentView?.previewButton.setImage(#imageLiteral(resourceName: "start-previewing"), for: .normal)
		self.contentView?.puppetView.stopPreviewing()
	}
	
	private func showPuppetName(puppetName: String) {
		if let puppet = AVTPuppet.puppetNamed(puppetName, options: nil) as? AVTPuppet {
			self.contentView?.puppetView.setValue(puppet, forKey: "avatarInstance")
		}
	}
}


