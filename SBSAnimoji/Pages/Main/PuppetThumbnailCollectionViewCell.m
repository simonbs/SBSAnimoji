//
//  PuppetThumbnailCollectionViewCell.m
//  SBSAnimoji
//
//  Created by Simon Støvring on 05/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "PuppetThumbnailCollectionViewCell.h"

@interface PuppetThumbnailCollectionViewCell ()
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIImageView *selectionImageView;
@end

@implementation PuppetThumbnailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setupView];
        [self setupLayout];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    
    self.thumbnailImageView = [[UIImageView alloc] init];
    self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.thumbnailImageView];
    
    self.selectionImageView = [[UIImageView alloc] init];
    self.selectionImageView.image = [UIImage imageNamed:@"selection"];
    self.selectionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionImageView.hidden = YES;
    [self.contentView addSubview:self.selectionImageView];
}

- (void)setupLayout {
    [self.thumbnailImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant: 7].active = YES;
    [self.thumbnailImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant: -7].active = YES;
    [self.thumbnailImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant: 7].active = YES;
    [self.thumbnailImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant: -7].active = YES;
    
    [self.selectionImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.selectionImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.selectionImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.selectionImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectionImageView.hidden = !selected;
}

@end
