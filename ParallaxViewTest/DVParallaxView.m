//
//  DVParallaxView.m
//  ParallaxViewTest
//
//  Created by Mikhail Grushin on 11.07.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVParallaxView.h"
#import <CoreMotion/CoreMotion.h>

#define DV_ROTATION_THRESHOLD 0.1f
#define DV_ROTATION_MULTIPLIER 2.5f

@interface DVParallaxView()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *contentOffsetLabel;
@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation DVParallaxView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parallaxDistanceFactor = 1.1f;
        self.parallaxFrontFactor = 20.f;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundImageView];
//        [self addSubview:self.contentOffsetLabel];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        [self addGestureRecognizer:panRecognizer];
    }
    return self;
}

#pragma mark - Getters

-(CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.03f;
    }
    
    return _motionManager;
}

-(UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeCenter;
        _backgroundImageView.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                  CGRectGetMidY(self.bounds));
    }
    
    return _backgroundImageView;
}

-(UILabel *)contentOffsetLabel {
    if (!_contentOffsetLabel) {
        _contentOffsetLabel = [[UILabel alloc] init];
        _contentOffsetLabel.backgroundColor = [UIColor clearColor];
        _contentOffsetLabel.textColor = [UIColor whiteColor];
        _contentOffsetLabel.center = CGPointMake(0.f,
                                                 2*_contentOffsetLabel.bounds.size.height);
    }
    
    return _contentOffsetLabel;
}

#pragma mark - Setters

-(void)setParallaxDistanceFactor:(float)parallaxDistanceFactor {
    _parallaxDistanceFactor = MAX(0.f, parallaxDistanceFactor);
}

-(void)setParallaxFrontFactor:(float)parallaxFrontFactor {
    _parallaxFrontFactor = MAX(0.f, parallaxFrontFactor);
}


-(void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self.backgroundImageView setImage:_backgroundImage];
    
    CGPoint origin = CGPointMake(CGRectGetMidX(self.bounds) - backgroundImage.size.width/2.f,
                                 CGRectGetMidY(self.bounds) - backgroundImage.size.height/2.f);
    
    self.backgroundImageView.frame = (CGRect){.origin = origin, .size = backgroundImage.size};
}

-(void)setFrontView:(UIView *)frontView {
    _frontView = frontView;
    [self addSubview:frontView];
}

-(void)setContentOffset:(CGPoint)contentOffset {
    BOOL backgroundReachedEdgeX = NO;
    BOOL backgroundReachedEdgeY = NO;
    double contentDivider;
    
    if (self.backgroundImageView) {
        contentDivider = self.subviews.count*self.parallaxDistanceFactor;
        CGPoint newCenter = CGPointMake(self.backgroundImageView.center.x + (contentOffset.x - _contentOffset.x)/contentDivider,
                                        self.backgroundImageView.center.y - (contentOffset.y - _contentOffset.y)/contentDivider);
        
        if ((newCenter.x - self.backgroundImageView.frame.size.width/2.f) > 0.f ||
            (newCenter.x + self.backgroundImageView.frame.size.width/2.f) < self.bounds.size.width) {
            newCenter.x = self.backgroundImageView.center.x;
            backgroundReachedEdgeX = YES;
        }
        
        if ((newCenter.y - self.backgroundImageView.frame.size.height/2.f) > 0.f ||
            (newCenter.y + self.backgroundImageView.frame.size.height/2.f) < self.bounds.size.height) {
            newCenter.y = self.backgroundImageView.center.y;
            backgroundReachedEdgeY = YES;
        }
        
        self.backgroundImageView.center = newCenter;
    }
    
    for (int i = 1; i<self.subviews.count; ++i) {
        UIView *view = [self.subviews objectAtIndex:i];
        contentDivider = (view == self.frontView)?-self.parallaxFrontFactor:((self.subviews.count - i)*self.parallaxDistanceFactor);
        CGFloat newCenterX = backgroundReachedEdgeX?view.center.x:(view.center.x + (contentOffset.x - _contentOffset.x)/contentDivider);
        CGFloat newCenterY = backgroundReachedEdgeY?view.center.y:(view.center.y - (contentOffset.y - _contentOffset.y)/contentDivider);
        view.center = CGPointMake(newCenterX, newCenterY);
    }
    
    _contentOffset = contentOffset;
}

-(void)setGyroscopeControl:(BOOL)gyroscopeControl {
    if (_gyroscopeControl == gyroscopeControl)
        return;
    
    _gyroscopeControl = gyroscopeControl;
    
    if (gyroscopeControl) {
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            [self setContentOffset:[self contentOffsetFromGyro:gyroData]];
        }];
    } else {
        [self.motionManager stopGyroUpdates];
        self.motionManager = nil;
    }
}

#pragma mark - Overriding

-(void)addSubview:(UIView *)view {
    if (self.frontView)
        [super insertSubview:view belowSubview:self.frontView];
    else
        [super addSubview:view];
}

#pragma mark - Gyroscope to offset
         
- (CGPoint)contentOffsetFromGyro:(CMGyroData *)gyroData {
    double xOffset = (fabs(gyroData.rotationRate.y) > DV_ROTATION_THRESHOLD)?gyroData.rotationRate.y*DV_ROTATION_MULTIPLIER:0.f;
    double yOffset = (fabs(gyroData.rotationRate.x) > DV_ROTATION_THRESHOLD)?gyroData.rotationRate.x*DV_ROTATION_MULTIPLIER:0.f;
    CGPoint newOffset = CGPointMake(self.contentOffset.x + xOffset,
                                    self.contentOffset.y + yOffset);
    [self updateInfoLabelWithRotationRate:gyroData.rotationRate];
    return newOffset;
}

#pragma mark - Gesture handler

- (void)panHandler:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    [self setContentOffset:CGPointMake(self.contentOffset.x + translation.x,
                                       self.contentOffset.y - translation.y)];
    
    [pan setTranslation:CGPointZero inView:self];
}

#pragma mark - Updating content offset info

- (void)updateInfoLabelWithRotationRate:(CMRotationRate)rotationRate {
    self.contentOffsetLabel.text = [NSString stringWithFormat:@"%.3f    %.3f    %.3f", rotationRate.x, rotationRate.y, rotationRate.z];
    [self.contentOffsetLabel sizeToFit];
}

@end
