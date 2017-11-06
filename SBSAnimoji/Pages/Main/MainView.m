//
//  MainView.m
//  SBSAnimoji
//
//  Created by Simon Støvring on 05/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "MainView.h"
#import "AVTPuppetView.h"

@interface MainView ()
@property (nonatomic, strong) SBSPuppetView *puppetView;
@property (nonatomic, strong) UICollectionView *thumbnailsCollectionView;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *puppetViewSeparatorView;
@end

@implementation MainView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
        [self setupLayout];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    
    self.puppetView = [[SBSPuppetView alloc] init];
    self.puppetView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.puppetView];
    
    self.puppetViewSeparatorView = [[UIView alloc] init];
    self.puppetViewSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.puppetViewSeparatorView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0];
    [self addSubview:self.puppetViewSeparatorView];
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.itemSize = CGSizeMake(80, 80);
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectionViewLayout.minimumInteritemSpacing = 14;
    collectionViewLayout.minimumLineSpacing = 10;
    self.thumbnailsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    self.thumbnailsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.thumbnailsCollectionView.backgroundColor = [UIColor whiteColor];
    self.thumbnailsCollectionView.contentInset = UIEdgeInsetsMake(15, 7, 15, 7);
    self.thumbnailsCollectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.thumbnailsCollectionView];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    self.durationLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.durationLabel.hidden = YES;
    [self addSubview:self.durationLabel];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.deleteButton.hidden = YES;
    [self.deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self addSubview:self.deleteButton];
    
    self.previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.previewButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewButton.hidden = YES;
    [self.previewButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self addSubview:self.previewButton];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.recordButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [self addSubview:self.recordButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.shareButton.hidden = YES;
    [self.shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self addSubview:self.shareButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:self.activityIndicatorView];
}

- (void)setupLayout {
    [self.puppetView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.puppetView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.puppetView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor].active = YES;
    [self.puppetView.heightAnchor constraintEqualToConstant:335].active = YES;
    
    [self.puppetViewSeparatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.puppetViewSeparatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.puppetViewSeparatorView.topAnchor constraintEqualToAnchor:self.puppetView.bottomAnchor].active = YES;
    [self.puppetViewSeparatorView.heightAnchor constraintEqualToConstant:2].active = YES;
    
    [self.thumbnailsCollectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.thumbnailsCollectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.thumbnailsCollectionView.topAnchor constraintEqualToAnchor:self.puppetViewSeparatorView.bottomAnchor].active = YES;
    [self.thumbnailsCollectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [self.durationLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -20].active = YES;
    [self.durationLabel.topAnchor constraintEqualToAnchor:self.puppetView.topAnchor constant: 15].active = YES;
    
    [self.recordButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -20].active = YES;
    [self.recordButton.bottomAnchor constraintEqualToAnchor:self.puppetView.bottomAnchor constant: -20].active = YES;

    [self.shareButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -20].active = YES;
    [self.shareButton.bottomAnchor constraintEqualToAnchor:self.puppetView.bottomAnchor constant: -20].active = YES;

    [self.deleteButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -20].active = YES;
    [self.deleteButton.topAnchor constraintEqualToAnchor:self.puppetView.topAnchor constant: 15].active = YES;
    
    [self.previewButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant: -20].active = YES;
    [self.previewButton.topAnchor constraintEqualToAnchor:self.deleteButton.bottomAnchor constant: 15].active = YES;

    [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.shareButton.centerXAnchor].active = YES;
    [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.shareButton.centerYAnchor].active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat itemsPerRow = 4;
    UICollectionView *collectionView = self.thumbnailsCollectionView;
    UIEdgeInsets contentInset = self.thumbnailsCollectionView.contentInset;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGFloat availableWidth = self.bounds.size.width - contentInset.left - contentInset.right - (itemsPerRow - 1) * flowLayout.minimumInteritemSpacing;
    CGFloat itemLength = floor(availableWidth / itemsPerRow);
    flowLayout.itemSize = CGSizeMake(itemLength, itemLength);
}

@end
