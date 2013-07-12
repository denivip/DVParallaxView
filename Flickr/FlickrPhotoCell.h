//
//  FlickrPhotoCell.h
//  ParallaxViewTest
//
//  Created by Mikhail Grushin on 12.07.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"

@interface FlickrPhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FlickrPhoto *photo;

@end
