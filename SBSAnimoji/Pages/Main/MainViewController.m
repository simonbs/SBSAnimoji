//
//  MainViewController.m
//  SBSAnimoji
//
//  Created by Simon Støvring on 05/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "AVTPuppet.h"
#import "AVTPuppetView.h"
#import "PuppetThumbnailCollectionViewCell.h"

@interface MainViewController () <SBSPuppetViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, readonly) MainView *contentView;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSArray *puppetNames;
@property (nonatomic, assign) BOOL hasExportedMovie;
@property (nonatomic, assign, getter=isExporting) BOOL exporting;
@end

@implementation MainViewController

// Pragma mark: - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        self.title = NSLocalizedString(@"MAIN_TITLE", @"");
        self.puppetNames = [AVTPuppet puppetNames];
    }
    return self;
}

- (void)dealloc {
    [self.contentView.puppetView removeObserver:self forKeyPath:@"recording"];
}

- (MainView *)contentView {
    return (MainView *)self.view;
}

- (void)loadView {
    self.view = [[MainView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.puppetView.sbsDelegate = self;
    self.contentView.thumbnailsCollectionView.dataSource = self;
    self.contentView.thumbnailsCollectionView.delegate = self;
    [self.contentView.thumbnailsCollectionView registerClass:[PuppetThumbnailCollectionViewCell class] forCellWithReuseIdentifier:@"thumbnail"];
    [self.contentView.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.deleteButton addTarget:self action:@selector(removeRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton addTarget:self action:@selector(startPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self showPuppetNamed:self.puppetNames[0]];
    [self.contentView.thumbnailsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

// Pragma mark: - Private

- (void)share {
    __weak typeof(self) weakSelf = self;
    [self exportMovieIfNecessary:^(NSURL *movieURL) {
        if (movieURL == nil) {
            return;
        }
        NSArray *activityItems = @[ movieURL ];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [weakSelf presentViewController:activityViewController animated:true completion:nil];
    }];
}

- (void)exportMovieIfNecessary:(void(^)(NSURL *))completion {
    NSURL *movieURL = [self movieURL];
    if (self.hasExportedMovie) {
        completion(movieURL);
    } else {
        self.exporting = YES;
        [self.contentView.activityIndicatorView startAnimating];
        self.contentView.deleteButton.enabled = NO;
        self.contentView.shareButton.hidden = YES;
        __weak typeof(self) weakSelf = self;
        [self.contentView.puppetView exportMovieToURL:movieURL options:nil completionHandler:^{
            weakSelf.hasExportedMovie = YES;
            [weakSelf.contentView.activityIndicatorView stopAnimating];
            weakSelf.contentView.deleteButton.enabled = YES;
            weakSelf.contentView.shareButton.hidden = NO;
            weakSelf.exporting = NO;
            completion(movieURL);
        }];
    }
}

- (void)removeRecording {
    self.hasExportedMovie = NO;
    [self removeExistingMovieFile];
    [self.contentView.puppetView stopRecording];
    [self.contentView.puppetView stopPreviewing];
    self.contentView.recordButton.hidden = NO;
    self.contentView.deleteButton.hidden = YES;
    self.contentView.previewButton.hidden = YES;
    self.contentView.shareButton.hidden = YES;
}

- (void)toggleRecording {
    if (self.contentView.puppetView.isRecording) {
        [self.contentView.puppetView stopRecording];
    } else {
        [self.contentView.puppetView startRecording];
    }
}

- (void)durationTimerTriggered {
    int recordingDuration = ceil(self.contentView.puppetView.recordingDuration);
    int minutes = floor(recordingDuration / 60);
    int seconds = recordingDuration % 60;
    NSString *strMinutes;
    NSString *strSeconds;
    if (minutes < 10) {
        strMinutes = [NSString stringWithFormat:@"0%d", minutes];
    } else {
        strMinutes = [NSString stringWithFormat:@"%d", minutes];
    }
    if (seconds < 10) {
        strSeconds = [NSString stringWithFormat:@"0%d", seconds];
    } else {
        strSeconds = [NSString stringWithFormat:@"%d", seconds];
    }
    self.contentView.durationLabel.text = [NSString stringWithFormat:@"%@:%@", strMinutes, strSeconds];
}

- (void)removeExistingMovieFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *movieURL = [self movieURL];
    if ([fileManager fileExistsAtPath:movieURL.path]) {
        NSError *error = nil;
        [fileManager removeItemAtURL:movieURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (void)startPreview {
    [self.contentView.previewButton removeTarget:self action:@selector(startPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton addTarget:self action:@selector(stopPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton setImage:[UIImage imageNamed:@"stop-previewing"] forState:UIControlStateNormal];
    [self.contentView.puppetView stopPreviewing];
    [self.contentView.puppetView startPreviewing];
}

- (void)stopPreview {
    [self.contentView.previewButton removeTarget:self action:@selector(stopPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton addTarget:self action:@selector(startPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton setImage:[UIImage imageNamed:@"start-previewing"] forState:UIControlStateNormal];
    [self.contentView.puppetView stopPreviewing];
}

- (NSURL *)movieURL {
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentURL URLByAppendingPathComponent:@"animoji.mov"];
}

- (void)showPuppetNamed:(NSString *)puppetName {
    AVTPuppet *puppet = [AVTPuppet puppetNamed:puppetName options:nil];
    [self.contentView.puppetView setAvatarInstance:(AVTAvatarInstance *)puppet];
}

// Pragma mark: - SBSPuppetViewDelegate

- (void)puppetViewDidFinishPlaying:(SBSPuppetView *)puppetView {
    if (!puppetView.isRecording) {
        [self stopPreview];
    }
}

- (void)puppetViewDidStartRecording:(SBSPuppetView *)puppetView {
    self.hasExportedMovie = NO;
    [self removeExistingMovieFile];
    [self.contentView.recordButton setImage:[UIImage imageNamed:@"stop-recording"] forState:UIControlStateNormal];
    self.contentView.durationLabel.text = @"00:00";
    self.contentView.durationLabel.hidden = NO;
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(durationTimerTriggered) userInfo:nil repeats:YES];
    self.contentView.thumbnailsCollectionView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.thumbnailsCollectionView.alpha = 0.5;
    }];
}

- (void)puppetViewDidStopRecording:(SBSPuppetView *)puppetView {
    if (self.isExporting) {
        // The callback is called when we start exporting.
        // It's not intuitive but internally, AVTPuppetView is
        // calling stopRecording which then triggers this callback.
        return;
    }
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    self.contentView.recordButton.hidden = YES;
    self.contentView.shareButton.hidden = NO;
    self.contentView.deleteButton.hidden = NO;
    self.contentView.previewButton.hidden = NO;
    self.contentView.durationLabel.hidden = YES;
    [self.contentView.recordButton setImage:[UIImage imageNamed:@"start-recording"] forState:UIControlStateNormal];
    self.contentView.thumbnailsCollectionView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.thumbnailsCollectionView.alpha = 1;
    }];
    [self startPreview];
}

// Pragma mark: - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.puppetNames count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PuppetThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    NSString *puppetName = self.puppetNames[indexPath.item];
    cell.thumbnailImageView.image = [AVTPuppet thumbnailForPuppetNamed:puppetName options:nil];
    return cell;
}

// Pragma mark: - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *puppetName = self.puppetNames[indexPath.item];
    if (puppetName != nil) {
        [self showPuppetNamed:puppetName];
    }
}

@end
