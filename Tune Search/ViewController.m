//
//  ViewController.m
//  Tune Search
//
//  Created by Andrew Conrad on 4/25/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "ViewController.h"
#import "Song.h"
#import "Reachability.h"
#import "DetailViewController.h"
#import "SongCollectionViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"


@interface ViewController ()

@property (nonatomic, strong)               AppDelegate         *appDelegate;
@property (nonatomic, strong)               NSString            *hostName;
@property (nonatomic, strong)               NSMutableArray      *songArray;
@property (nonatomic, weak)     IBOutlet    UICollectionView    *songsCollectionView;
@property (nonatomic, strong)   IBOutlet    UISearchBar         *searchBar;


//Stuff for animations
@property (nonatomic, weak)     IBOutlet        UIView              *menuView;
@property (nonatomic, weak)     IBOutlet        NSLayoutConstraint  *menuTopConstraint;
@property (nonatomic, weak)     IBOutlet        NSLayoutConstraint  *collectionTopConstraint;
@property (nonatomic, weak)     IBOutlet        NSLayoutConstraint  *collectionBottomConstraint;


@end

@implementation ViewController

Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;

//[[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppearance) name:UIKeyboardWillShowNotification object:nil];


//[[[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(_keyboardWillShow:)
//                                             name:UIKeyboardWillShowNotification
//                                           object:nil];

#pragma mark - Animation Methods


- (IBAction)toggleMenuView:(id)sender {
    NSLog(@"Toggle");
    if (_menuView.hidden) {
        [_menuView setHidden:false];
        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //[_menuView setAlpha:1.0];
            _menuTopConstraint.constant = 0.0;
            _collectionTopConstraint.constant = 0.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            //
        }];
    } else {
        {[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //[_menuView setAlpha:0.0];
            _menuTopConstraint.constant = -1 * (_menuView.frame.size.height + self.navigationController.navigationBar.frame.size.height);
            _collectionTopConstraint.constant = 44.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_menuView setHidden:true];
        }];
        }
    }
}

- (IBAction)searchSelectGesture:(UIGestureRecognizer *)gesture {
    

}

#pragma mark - File System Methods

- (BOOL)file:(NSString *)filename isInDirectory: (NSString *)directory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [directory stringByAppendingPathComponent:filename];
    return [fileManager fileExistsAtPath:filePath];
    
}

#pragma mark - Collection View Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _songArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SongCollectionViewCell *cell = (SongCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Song *currentSong = _songArray[indexPath.row];
    cell.songNameLabel.text = currentSong.songName;
    
    if ([self file:currentSong.songLocalImageFilename isInDirectory:[_appDelegate getDocumentsDirectory]]) {
//        NSLog(@"Found %@",currentSong.songImageFilename);
        cell.songImageView.image = [UIImage imageNamed:[[_appDelegate getDocumentsDirectory] stringByAppendingPathComponent:currentSong.songLocalImageFilename]];
    } else {
//        NSLog(@"Not Found %@",currentSong.songImageFilename);
        [self getImageFromServer:currentSong.songLocalImageFilename fromUrl:currentSong.songImageFilename atIndexPath:indexPath];
    }
    
    return cell;
    
}


#pragma mark - Network Methods

- (void)updateReachabilityStatus:(Reachability *)currentReach {
    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    if (currentReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Server Not Available");
                serverAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Server Reachable via WWAN");
                serverAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = true;
            default:
                break;
        }
    }
    if (currentReach == internetReach || currentReach == wifiReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Internet Not Available");
                internetAvailable = false;
                break;
            case ReachableViaWWAN:
                NSLog(@"Internet Available via WWAN");
                internetAvailable = true;
            case ReachableViaWiFi:
                NSLog(@"Internet Available via WiFi");
                internetAvailable = true;
            default:
                break;
        }
    }
}



- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *currentReach = [notification object];
    [self updateReachabilityStatus:currentReach];
}

- (void)getImageFromServer: (NSString *) localFileName fromUrl:(NSString *)fullFileName atIndexPath:(NSIndexPath *) indexPath {
    if (serverAvailable) {
//        NSLog(@"local:%@ url:%@",localFileName, fullFileName);
        NSURL *fileURL = [NSURL URLWithString:fullFileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] > 0) && (error == nil)) {
                NSString *savedFilePath = [[_appDelegate getDocumentsDirectory] stringByAppendingPathComponent:localFileName];
                UIImage *imageTemp = [UIImage imageWithData:data];
                if (imageTemp != nil) {
                    [data writeToFile:savedFilePath atomically:true];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_songsCollectionView reloadItemsAtIndexPaths:@[indexPath]];

                    });
                }
            } else {
            }
        }]resume];
    } else {
        NSLog(@"Server Not Availible");
        
    }

}

#pragma mark - Interactivity Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *destController = [segue destinationViewController];
    NSIndexPath *indexPath = [_songsCollectionView indexPathsForSelectedItems][0];
    destController.currentSong = [_songArray objectAtIndex:indexPath.row];
    
}

- (IBAction)searchButton:(id)sender {
    [_searchBar resignFirstResponder];

    _collectionBottomConstraint.constant = 1.0;
    NSLog(@"%f",_collectionBottomConstraint.constant);
    
    if (serverAvailable) {
        
        NSString *artistSearchString = _searchBar.text;
        
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/search?term=%@",_hostName,artistSearchString]];
 //       NSLog(@"Searching for %@",artistSearchString);
        
        //
        //
        //data verification to make lower case and replace with + sings
        //
        //
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Got Response");
            if (([data length] > 0) && (error == nil)) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSArray *tempArray = [(NSDictionary *)json objectForKey:@"results"];
                [_songArray removeAllObjects];
                
                for (NSDictionary *songDict in tempArray) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    formatter.dateFormat = @"yyyy-MM-dd";
                  
                    Song *newSong = [[Song alloc] initWithName:[songDict objectForKey:@"trackName"]
                                              andCollectionUrl:[songDict objectForKey:@"collectionViewUrl"] andImageName:[songDict objectForKey:@"artworkUrl100"]
                                                     andSample:[songDict objectForKey:@"previewUrl"]
                                                 andCollection:[songDict objectForKey:@"previewUrl"]];
                    
                    newSong.songLocalImageFilename = [NSString stringWithFormat:@"%@.jpg",[songDict objectForKey:@"trackId"]];
                    [_songArray addObject:newSong];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_songsCollectionView reloadData];
                });
            }
        }] resume];

    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Not Available" message:@"Hey, turn on your Internet. Or maybe the server's down. Call for help" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:nil];
    }
}



#pragma mark - Life Cycle Methods

//keyboard changes start
//The NSLog says thats its working but I can't tell. So I think its done?
//Have a look anyway if you are reading this cobbled together code mess

- (void)observeKeyboard {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppearance:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardAppearance:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *keyboardFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardHeight = [keyboardFrame CGRectValue];
    CGFloat height = keyboardHeight.size.height;
    
    _collectionBottomConstraint.constant = height;
    NSLog(@"%f",_collectionBottomConstraint.constant);
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

//keyboard changes end

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"itunes.apple.com";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    hostReach = [Reachability reachabilityWithHostname:_hostName];
    [hostReach startNotifier];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    
    _songArray = [[NSMutableArray alloc]init];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    [self observeKeyboard];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
