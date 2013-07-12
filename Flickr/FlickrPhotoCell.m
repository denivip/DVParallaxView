//
//  FlickrPhotoCell.m
//  ParallaxViewTest
//
//  Created by Mikhail Grushin on 12.07.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "FlickrPhotoCell.h"

@implementation FlickrPhotoCell

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

-(void)setImageView:(UIImageView *)imageView {
    [_imageView removeFromSuperview];
    _imageView = imageView;
    [self addSubview:_imageView];
}

-(void)setPhoto:(FlickrPhoto *)photo {
    if (_photo != photo) {
        _photo = photo;
    }
    
    self.imageView.image = _photo.thumbnail;
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                      self.imageView.frame.origin.y,
                                      self.imageView.image.size.width,
                                      self.imageView.image.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
