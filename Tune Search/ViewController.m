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


@interface ViewController ()

@property (nonatomic, strong)               NSString            *hostName;
@property (nonatomic, strong)               NSMutableArray      *songArray;
@property (nonatomic, weak)     IBOutlet    UICollectionView    *songsCollectionView;
@property (nonatomic, weak)     IBOutlet    UITextField         *artistSearchTextField;

//collectionViewUrl is the key for the in app browser

@end

@implementation ViewController

Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;

#pragma mark - File System Methods

- (NSString *)getDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSLog(@"doc path %@",paths[0]);
    return paths[0];
    
}

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
    
    if ([self file:currentSong.songLocalImageFilename isInDirectory:[self getDocumentsDirectory]]) {
        NSLog(@"Found %@",currentSong.songImageFilename);
        cell.songImageView.image = [UIImage imageNamed:[[self getDocumentsDirectory] stringByAppendingPathComponent:currentSong.songLocalImageFilename]];
    } else {
        NSLog(@"Not Found %@",currentSong.songImageFilename);
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
        NSLog(@"local:%@ url:%@",localFileName, fullFileName);
        NSURL *fileURL = [NSURL URLWithString:fullFileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] > 0) && (error == nil)) {
                NSString *savedFilePath = [[self getDocumentsDirectory] stringByAppendingPathComponent:localFileName];
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
    if (serverAvailable) {
        
        NSString *artistSearchString = _artistSearchTextField.text;
        
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/search?term=%@",_hostName,artistSearchString]];
        NSLog(@"Searching for %@",artistSearchString);
        
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
                    
                    Song *newSong = [[Song alloc]initWithName:[songDict objectForKey:@"trackName"]
                                             andCollectionUrl:[songDict objectForKey:@"collectionViewUrl"]
                                                 andImageName:[songDict objectForKey:@"artworkUrl100"]
                                                andCollection:[songDict objectForKey:@"collectionName"]];

                    newSong.songLocalImageFilename = [NSString stringWithFormat:@"%@.jpg",[songDict objectForKey:@"trackId"]];
                    [_songArray addObject:newSong];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    //
                    //main thread code goes here
                    //BUT THIS COMMENT WAS COPIED FROM CLASS WHAT DOES IT MEAAAANNNNN
                    //
                    //
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
