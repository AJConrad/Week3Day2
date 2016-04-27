//
//  DetailViewController.m
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "DetailViewController.h"
#import <Social/Social.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
