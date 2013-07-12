//
//  DVViewController.m
//  ParallaxViewTest
//
//  Created by Mikhail Grushin on 11.07.13.
//  Copyright (c) 2013 DENIVIP Group. All rights reserved.
//

#import "DVViewController.h"
#import "DVParallaxView.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoCell.h"

@interface DVViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) DVParallaxView *parallaxView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary *searchResults;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) Flickr *flickr;
@end

@implementation DVViewController

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(25.f, 30.f, 380.f, 550.f) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[FlickrPhotoCell class] forCellWithReuseIdentifier:@"FlickrCell"];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.userInteractionEnabled = NO;
    }
    
    return _collectionView;
}

-(NSMutableDictionary *)searchResults {
    if (!_searchResults) {
        _searchResults = [@{} mutableCopy];
    }
    
    return _searchResults;
}

-(Flickr *)flickr {
    if (!_flickr) {
        _flickr = [[Flickr alloc] init];
    }
    
    return _flickr;
}

-(DVParallaxView *)parallaxView {
    if (!_parallaxView) {
        _parallaxView = [[DVParallaxView alloc] initWithFrame:self.view.bounds];
        [_parallaxView setBackgroundImage:[UIImage imageNamed:@"galaxy2"]];
        
        UIImageView *earth = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earth"]];
        [_parallaxView addSubview:earth];
        
        UIImageView *moon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon"]];
        [_parallaxView addSubview:moon];
        
        _parallaxView.gyroscopeControl = YES;
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        for (int i=0; i<15; ++i) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(25.f+(i%3)*110.f,
                                      30.f+(i/3)*100.f,
                                      50.f, 50.f);
            [button setTitle:[NSString stringWithFormat:@"%d", i+1] forState:UIControlStateNormal];
            [view addSubview:button];
        }
        [_parallaxView setFrontView:self.collectionView];
    }
    
    return _parallaxView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.parallaxView];
    [self.view sendSubviewToBack:self.parallaxView];
    
    [self.flickr searchFlickrForTerm:@"Eiffel" completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if (results && results.count>0) {
            self.searchTerm = searchTerm;
            self.searchResults[searchTerm] = results;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"Error searching flickr");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    self.parallaxView.frame = self.view.bounds;
    [self.parallaxView setNeedsLayout];
}

#pragma mark - UICollectionView data source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    cell.photo = self.searchResults[self.searchTerm][indexPath.row];
    cell.clipsToBounds = YES;
    return cell;
}

#pragma mark - UICollectionView flow layout delegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhoto *photo = self.searchResults[self.searchTerm][indexPath.row];
    CGSize retval = CGSizeMake(50.f, 50.f);
    retval.height += 10;
    retval.width += 10;
    
    return retval;
}

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(50.f, 20.f, 50.f, 20.f);
//}

@end
