//
//  Song.m
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import "Song.h"

@implementation Song

- (id)initWithName:(NSString *)songName andImageName:(NSString *)imageName andCollection:(NSString *)collectionName {
    self = [super init];
    if (self) {
        self.songName = songName;
        self.songImageFilename = imageName;
        self.collectionName = collectionName;
    }
    return self;
}

@end
