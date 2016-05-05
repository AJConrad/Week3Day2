//
//  Song.m
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "Song.h"

@implementation Song

//- (id) initWithName:(NSString *)songName andCollectionUrl:(NSString *)collectionUrl andImageName:(NSString *)imageName andCollection:(NSString *)collectionName

- (id) initWithName:(NSString *)songName andCollectionUrl:(NSString *)collectionUrl andImageName:(NSString *)imageName andSample:(NSString *)previewUrl andCollection:(NSString *)collectionName;

{
    self = [super init];
    if (self) {
        self.songName = songName;
        self.songImageFilename = imageName;
        self.collectionName = collectionName;
        self.collectionViewUrl = collectionUrl;
        self.sampleURL = previewUrl;
        
    }
    return self;
}

@end
