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
@property (nonatomic, strong)   NSString    *collectionViewUrl;
@property (nonatomic, strong)   NSString    *sampleURL;


- (id) initWithName:(NSString *)songName andCollectionUrl:(NSString *)collectionUrl andImageName:(NSString *)imageName andSample:(NSString *)previewUrl andCollection:(NSString *)collectionName;

@end
