//
//  SongCollectionViewCell.h
//  Tune Search
//
//  Created by Andrew Conrad on 4/27/16.
//  Copyright © 2016 AndrewConrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak)     IBOutlet        UIImageView     *songImageView;
@property (nonatomic, weak)     IBOutlet        UILabel         *songNameLabel;

@end
