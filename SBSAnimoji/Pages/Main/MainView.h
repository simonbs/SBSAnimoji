//
//  MainView.h
//  SBSAnimoji
//
//  Created by Simon Støvring on 05/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBSPuppetView.h"

@class AVTPuppetView;

@interface MainView : UIView
@property (nonatomic, readonly) SBSPuppetView *puppetView;
@property (nonatomic, readonly) UICollectionView *thumbnailsCollectionView;
@property (nonatomic, readonly) UIButton *recordButton;
@property (nonatomic, readonly) UIButton *shareButton;
@property (nonatomic, readonly) UIButton *deleteButton;
@property (nonatomic, readonly) UIButton *previewButton;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UILabel *durationLabel;
@end
