//
//  DetailViewController.h
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import <MessageUI/MessageUI.h>

@interface DetailViewController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong)   Song    *currentSong;

@end
