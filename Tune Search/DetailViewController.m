//
//  DetailViewController.m
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "DetailViewController.h"
#import <Social/Social.h>
#import <safariServices/SafariServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface DetailViewController ()

@property (nonatomic, strong)                       AppDelegate             *appDelegate;
@property (nonatomic, weak)         IBOutlet        UIImageView             *albumCoverView;

@property (nonatomic, strong)                       AVPlayer                *audioPlayer;
@property (nonatomic, strong)                       AVSpeechSynthesizer     *synthesizer;

@end

CGFloat lastScale;
CGFloat lastRotation;

@implementation DetailViewController

#pragma mark - Internet Buttons

- (IBAction)safariButtonPressed:(id)sender {
    NSLog(@"Show Safari");
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL: [NSURL URLWithString:_currentSong.collectionViewUrl]];
    [self.navigationController presentViewController:safariVC animated:true completion:nil];
    
}

#pragma mark - Share Buttons

- (IBAction) emailButtonSent:(id)sender {
    NSLog(@"EMail");
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc]init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject:[NSString stringWithFormat:@"%@ is a great song!",_currentSong.songName]];
        [mailVC setMessageBody:@"Super awesome dude!" isHTML:false];
        [mailVC setToRecipients:@[@"tom@theironyard.com"]];
        [self.navigationController presentViewController:mailVC animated:true completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)smsButtonSent:(id)sender {
    NSLog(@"SMS");
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *textVC = [[MFMessageComposeViewController alloc] init];
        textVC.body = [NSString stringWithFormat:@"I LOVE %@",_currentSong.songName];
        textVC.messageComposeDelegate = self;
        [self.navigationController presentViewController:textVC animated:true completion:nil];
        
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:true completion:nil];
    
}


- (IBAction)fbButtonSent:(id)sender {
    NSLog(@"Facebook");
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbVC setInitialText:[NSString stringWithFormat:@"I LOVE %@",_currentSong.songName]];
        [self.navigationController presentViewController:fbVC animated:true completion:nil];
    }
}

- (IBAction)whereverButtonSent:(id)sender {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[[NSString stringWithFormat:@"I LOVE %@",_currentSong.songName]] applicationActivities:nil];
    [self.navigationController presentViewController:activityVC animated:true completion:nil];
}

#pragma mark - Audio and Image Methods

- (IBAction)sampleBarButton:(UIBarButtonItem *)button {
    if ([button.title isEqualToString:@"Play Song Sample"]) {
        button.title = @"Pause Song Sample";
        [_audioPlayer play];
        NSLog(@"Started Playing");
        
    } else {
        button.title = @"Play Song Sample";
        [_audioPlayer pause];
    }
}

- (void) playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if (playerItem == _audioPlayer.currentItem) {
        [_audioPlayer.currentItem seekToTime:kCMTimeZero];
        [_audioPlayer pause];
    }
}

- (IBAction)imagePincher:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    CGFloat scale = 1.0 - (lastScale - gesture.scale);
    CGAffineTransform currentTransform = _albumCoverView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [_albumCoverView setTransform:newTransform];
    lastScale = gesture.scale;
}

- (IBAction)imageRotator:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        lastRotation = 0;
        return;
    }
    CGFloat rotation = 0.0 - (lastRotation -gesture.rotation);
    CGAffineTransform currentTransform = _albumCoverView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);
    [_albumCoverView setTransform:newTransform];
    lastRotation = gesture.rotation;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    _albumCoverView.image = [UIImage imageNamed:[[_appDelegate getDocumentsDirectory]stringByAppendingPathComponent:_currentSong.songLocalImageFilename]];
    
    NSURL *sample = [NSURL URLWithString:_currentSong.sampleURL];
    NSLog(@"URL To play: %@",_currentSong.sampleURL);
    _audioPlayer = [AVPlayer playerWithURL:sample];
    _audioPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_audioPlayer currentItem]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
