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
@import YouTubeKit;
@import AVFoundation;

@interface MainViewController () <SBSPuppetViewDelegate, YouTubePickerViewControllerDelegate, YouTubePlayerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, readonly) MainView *contentView;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSArray *puppetNames;
@property (nonatomic, assign) BOOL hasExportedMovie;
@property (nonatomic, assign) BOOL hasRecording;
@property (nonatomic, assign, getter=isExporting) BOOL exporting;
@property (nonatomic, copy) NSString *youTubeVideoId;
@property (nonatomic, assign) CMTime audioStartTime;
@property (nonatomic, assign) CMTime audioEndTime;
@property (nonatomic, strong) YouTubePlayerViewController *playerViewController;
@property (nonatomic, strong) YouTubeMergerOperation *youTubeMergerOperation;
@property (nonatomic, readonly) BOOL isReadyForMergingYouTubeAudio;
@property (nonatomic, strong) NSString *youTubeAPIKey;
@end

@implementation MainViewController

// Pragma mark: - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        self.title = NSLocalizedString(@"MAIN_TITLE", @"");
        self.puppetNames = [AVTPuppet puppetNames];
        self.playerViewController = [[YouTubePlayerViewController alloc] init];
        self.playerViewController.delegate = self;
        self.hasRecording = NO;
        NSString *youTubeAPIKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SBSYouTubeAPIKey"];
        if (youTubeAPIKey != nil && youTubeAPIKey.length > 0) {
            self.youTubeAPIKey = youTubeAPIKey;
        }
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
    [self.contentView.pickAudioButton addTarget:self action:@selector(pickAudio) forControlEvents:UIControlEventTouchUpInside];
    [self showPuppetNamed:self.puppetNames[0]];
    [self.contentView.thumbnailsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self addChildViewController:self.playerViewController];
    [self.contentView addPlayerView:self.playerViewController.view];
    [self.playerViewController didMoveToParentViewController:self];
    [self updateThumbnailsContentInset];
    self.contentView.pickAudioButton.hidden = self.youTubeAPIKey == nil;
}

// Pragma mark: - Private

- (void)updateThumbnailsContentInset {
    UIEdgeInsets defaultContentInsets = UIEdgeInsetsMake(15, 7, 15, 7);
    BOOL showsYouTubeVideo = self.youTubeVideoId != nil;
    if (showsYouTubeVideo) {
        CGFloat playerContainerBottomSpacing = self.view.bounds.size.height - CGRectGetMinY(self.contentView.playerContainerView.frame);
        self.contentView.thumbnailsCollectionView.contentInset = UIEdgeInsetsMake(defaultContentInsets.top, defaultContentInsets.left, defaultContentInsets.bottom + playerContainerBottomSpacing, defaultContentInsets.right);
    } else {        
        self.contentView.thumbnailsCollectionView.contentInset = defaultContentInsets;
    }
}

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
    NSURL *animojiMovieURL = [self animojiMovieURL];
    if (self.hasExportedMovie) {
        completion(animojiMovieURL);
    } else {
        self.exporting = YES;
        [self.contentView.activityIndicatorView startAnimating];
        self.contentView.deleteButton.enabled = NO;
        self.contentView.shareButton.hidden = YES;
        __weak typeof(self) weakSelf = self;
        [self.contentView.puppetView exportMovieToURL:animojiMovieURL options:nil completionHandler:^{
            void(^didFinishExport)(NSURL*) = ^void(NSURL *movieURL) {
                weakSelf.hasExportedMovie = YES;
                [weakSelf.contentView.activityIndicatorView stopAnimating];
                weakSelf.contentView.deleteButton.enabled = YES;
                weakSelf.contentView.shareButton.hidden = NO;
                weakSelf.exporting = NO;
                completion(movieURL);
            };
            if (weakSelf.isReadyForMergingYouTubeAudio) {
                [weakSelf mergeYouTubeVideoId:self.youTubeVideoId intoAnimojiVideo:animojiMovieURL audioStartTime:self.audioStartTime audioEndTime:self.audioEndTime completion:^(NSURL *mergedMovieURL) {
                    if (mergedMovieURL == nil) {
                        return;
                    }
                    didFinishExport(mergedMovieURL);
                }];
            } else {
                didFinishExport(animojiMovieURL);
            }
        }];
    }
}

- (void)mergeYouTubeVideoId:(NSString *)videoId intoAnimojiVideo:(NSURL *)animojiVideoURL audioStartTime:(CMTime)audioStartTime audioEndTime:(CMTime)audioEndTime completion:(void(^)(NSURL*))completion {
    YouTubeMerger *merger = [[YouTubeMerger alloc] init];
    [self removeExistingMergedMovieFile];
    NSURL *exportURL = [self mergedMovieURL];
    [self.youTubeMergerOperation cancel];
    self.youTubeMergerOperation = [merger mergeWithAnimojiVideoURL:animojiVideoURL videoId:videoId startTime:audioStartTime endTime:audioEndTime exportURL:exportURL success:^(NSURL * _Nonnull movieURL) {
        completion(movieURL);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)removeRecording {
    self.hasExportedMovie = NO;
    self.hasRecording = NO;
    [self removeExistingAnimojiMovieFile];
    [self.contentView.puppetView stopRecording];
    [self.contentView.puppetView stopPreviewing];
    self.contentView.recordButton.hidden = NO;
    self.contentView.deleteButton.hidden = YES;
    self.contentView.previewButton.hidden = YES;
    self.contentView.shareButton.hidden = YES;
    [self.playerViewController showControls];
    [self.playerViewController pause];
}

- (void)toggleRecording {
    if (self.contentView.puppetView.isRecording) {
        self.audioEndTime = self.playerViewController.currentTime;
        self.hasRecording = YES;
        [self.contentView.puppetView stopRecording];
    } else {
        self.audioStartTime = self.playerViewController.currentTime;
        [self.contentView.puppetView startRecording];
        if (self.youTubeVideoId != nil) {
            [self.playerViewController hideControls];
            [self.playerViewController play];
        }
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

- (void)startPreview {
    [self.contentView.previewButton removeTarget:self action:@selector(startPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton addTarget:self action:@selector(stopPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton setImage:[UIImage imageNamed:@"stop-previewing"] forState:UIControlStateNormal];
    [self.contentView.puppetView stopPreviewing];
    [self.contentView.puppetView startPreviewing];
    if (self.isReadyForMergingYouTubeAudio) {
        self.contentView.puppetView.mute = YES;
        [self.playerViewController seekTo:self.audioStartTime];
        [self.playerViewController play];
    }
}

- (void)stopPreview {
    [self.contentView.previewButton removeTarget:self action:@selector(stopPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton addTarget:self action:@selector(startPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView.previewButton setImage:[UIImage imageNamed:@"start-previewing"] forState:UIControlStateNormal];
    [self.contentView.puppetView stopPreviewing];
    if (self.isReadyForMergingYouTubeAudio) {
        [self.playerViewController pause];
        self.contentView.puppetView.mute = NO;
        [self.playerViewController seekTo:self.audioStartTime];
    }
}

- (void)showPuppetNamed:(NSString *)puppetName {
    AVTPuppet *puppet = [AVTPuppet puppetNamed:puppetName options:nil];
    [self.contentView.puppetView setAvatarInstance:(AVTAvatarInstance *)puppet];
}

- (void)pickAudio {
    [self.playerViewController removeVideo];
    YouTubePickerViewController *youTubePickerViewController = [[YouTubePickerViewController alloc] initWithKey:self.youTubeAPIKey];
    youTubePickerViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:youTubePickerViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)removeExistingAnimojiMovieFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *movieURL = [self animojiMovieURL];
    if ([fileManager fileExistsAtPath:movieURL.path]) {
        NSError *error = nil;
        [fileManager removeItemAtURL:movieURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (void)removeExistingMergedMovieFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *movieURL = [self mergedMovieURL];
    if ([fileManager fileExistsAtPath:movieURL.path]) {
        NSError *error = nil;
        [fileManager removeItemAtURL:movieURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}

- (BOOL)isReadyForMergingYouTubeAudio {
    BOOL hasYouTubeVideoId = self.youTubeVideoId != nil;
    BOOL hasAudioStartTime = CMTIME_COMPARE_INLINE(self.audioStartTime, !=, kCMTimeInvalid);
    BOOL hasAudioEndTime = CMTIME_COMPARE_INLINE(self.audioEndTime, !=, kCMTimeInvalid);
    return hasYouTubeVideoId && hasAudioStartTime && hasAudioEndTime;
}

- (NSURL *)animojiMovieURL {
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentURL URLByAppendingPathComponent:@"animoji.mov"];
}

- (NSURL *)mergedMovieURL {
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentURL URLByAppendingPathComponent:@"merged.mov"];
}

// Pragma mark: - SBSPuppetViewDelegate

- (void)puppetViewDidFinishPlaying:(SBSPuppetView *)puppetView {
    if (!puppetView.isRecording) {
        [self stopPreview];
    }
}

- (void)puppetViewDidStartRecording:(SBSPuppetView *)puppetView {
    self.hasExportedMovie = NO;
    [self removeExistingAnimojiMovieFile];
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
    if (self.hasRecording) {
        [self startPreview];
    }
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

// MARK - YouTubePickerViewControllerDelegate

- (void)youTubePickerViewController:(YouTubePickerViewController *)youTubePickerViewController didPickVideoWithId:(NSString *)videoId {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.playerViewController showVideoWithId:videoId];
    self.contentView.playerContainerView.hidden = NO;
}

// MARK - YouTubePlayerViewControllerDelegate

- (void)youTubePlayerViewController:(YouTubePlayerViewController *)youTubePlayerViewController didLoadVideoWithId:(NSString *)videoId {
    self.youTubeVideoId = videoId;
    [self updateThumbnailsContentInset];
}

- (void)youTubePlayerViewControllerDidFinish:(YouTubePlayerViewController *)youTubePlayerViewController {}

- (void)youTubePlayerViewControllerDidClose:(YouTubePlayerViewController *)youTubePlayerViewController {
    self.youTubeVideoId = nil;
    self.audioStartTime = kCMTimeInvalid;
    self.audioEndTime = kCMTimeInvalid;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.playerContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        self.contentView.playerContainerView.hidden = YES;
        self.contentView.playerContainerView.alpha = 1;
        [self.playerViewController removeVideo];
    }];
    [self updateThumbnailsContentInset];
}

@end
