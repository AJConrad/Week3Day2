//
//  Song.h
//  Tune Search
//
//  Created by Andrew Conrad on 4/26/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

@property (nonatomic, strong)   NSString    *songName;
@property (nonatomic, strong)   NSString    *songImageFilename;
@property (nonatomic, strong)   NSString    *songLocalImageFilename;
@property (nonatomic, strong)   NSString    *collectionName;

- (id) initWithName:(NSString *)songName andImageName:(NSString *)imageName andCollection:(NSString *)collectionName;

@end
