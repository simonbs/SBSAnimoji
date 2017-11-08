//
//  UIImage+YouTubeKit.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 09/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(sbs_imageNamed imageName: String) {
        let bundle = Bundle(for: YouTubePlayerViewController.self)
        self.init(named: imageName, in: bundle, compatibleWith: nil)
    }
}
