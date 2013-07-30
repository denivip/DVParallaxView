//
//  DVViewController.m
//  ParallaxViewTest
//
//  Created by Mikhail Grushin on 11.07.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVViewController.h"
#import "DVParallaxView.h"

@interface DVViewController ()
@property (nonatomic, strong) DVParallaxView *parallaxView;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@end

@implementation DVViewController

-(DVParallaxView *)parallaxView {
    if (!_parallaxView) {
        _parallaxView = [[DVParallaxView alloc] initWithFrame:self.view.bounds];
        [_parallaxView setBackgroundImage:[UIImage imageNamed:@"galaxy2"]];
        
        UIImageView *earth = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earth"]];
        earth.frame = (CGRect) {.origin = CGPointMake(CGRectGetMidX(self.view.bounds) - earth.image.size.width/2.f,
                                                      CGRectGetMidY(self.view.bounds) - earth.image.size.height/2.f),
                                .size = earth.frame.size};
        [_parallaxView addSubview:earth];
        
        UIImageView *moon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon"]];
        moon.frame = (CGRect) {.origin = CGPointMake(CGRectGetMidX(self.view.bounds) + 30.f,
                                                      CGRectGetMidY(self.view.bounds) + 30.f),
            .size = moon.frame.size};
        [_parallaxView addSubview:moon];
        
        _parallaxView.gyroscopeControl = YES;
        [_parallaxView setFrontView:self.frontView];
    }
    
    return _parallaxView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.parallaxView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    self.parallaxView.frame = self.view.bounds;
}

@end
