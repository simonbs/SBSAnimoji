//
//  SBSPuppetView.swift
//  Animoji
//
//  Created by Daniel Illescas Romero on 25/12/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import UIKit

@objc protocol SBSPuppetViewDelegate: NSObjectProtocol {
	func puppetViewDidFinishPlaying(puppetView: SBSPuppetView)
	func puppetViewDidStartRecording(puppetView: SBSPuppetView)
	func puppetViewDidStopRecording(puppetView: SBSPuppetView)
}

@objc class SBSPuppetView: AVTPuppetView {
	
	var sbsDelegate: SBSPuppetViewDelegate?
	
	override public func audioPlayerItemDidReachEnd(_ arg1: Any!) {
		super.audioPlayerItemDidReachEnd(arg1)
		if self.sbsDelegate?.responds(to: #selector(self.sbsDelegate?.puppetViewDidFinishPlaying(puppetView:))) == true {
			self.sbsDelegate?.puppetViewDidFinishPlaying(puppetView: self)
		}
	}
	
	override func startRecording() {
		super.startRecording()
		
		let recordingDuration = 60 // seconds
		
		let duration = recordingDuration * 60
		
		let timesBuffer = NSMutableData(capacity: duration * 8)
		let blendShapeBuffer = NSMutableData(capacity: duration * 204)
		let transformData = NSMutableData(capacity: duration * 64)
		
		self.setValue(duration, forKey: "_recordingCapacity")
		self.setValue(timesBuffer, forKey: "_rawTimesData")
		self.setValue(blendShapeBuffer, forKey: "_rawBlendShapesData")
		self.setValue(transformData, forKey: "_rawTransformsData")
		
		if let ivarRawTimes = class_getInstanceVariable(AVTPuppetView.self, "_rawTimes") {
			object_setIvar(self, ivarRawTimes, timesBuffer?.mutableBytes)
		}
		
		if let ivarBlendShapes = class_getInstanceVariable(AVTPuppetView.self, "_rawBlendShapes") {
			object_setIvar(self, ivarBlendShapes, blendShapeBuffer?.mutableBytes)
		}
		
		if let ivarRawTransforms = class_getInstanceVariable(AVTPuppetView.self, "_rawTransforms") {
			object_setIvar(self, ivarRawTransforms, transformData?.mutableBytes)
		}
		
		if self.sbsDelegate?.responds(to: #selector(self.sbsDelegate?.puppetViewDidStartRecording(puppetView:))) == true {
			self.sbsDelegate?.puppetViewDidStartRecording(puppetView: self)
		}
	}
	
	override func stopRecording() {
		super.stopRecording()
		if self.sbsDelegate?.responds(to: #selector(self.sbsDelegate?.puppetViewDidStopRecording(puppetView:))) == true {
			self.sbsDelegate?.puppetViewDidStopRecording(puppetView: self)
		}
	}
}
