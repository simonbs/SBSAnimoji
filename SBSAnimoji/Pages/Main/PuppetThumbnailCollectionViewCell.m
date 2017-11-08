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

- (void)layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets thumbnailMargins = UIEdgeInsetsMake(7, 7, 7, 7);
    self.thumbnailImageView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, thumbnailMargins);
    self.selectionImageView.frame = self.contentView.bounds;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectionImageView.hidden = !selected;
}

@end
