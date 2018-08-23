//
//  PhotosViewController.m
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 7/30/18.
//  Copyright © 2018 none. All rights reserved.
//

#import "PhotosViewController.h"
#import "FlickrPhotoCell.h"
#import "FlickrManager.h"
#import "Photo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <KSPhotoBrowser/KSSDImageManager.h>
#import <KSPhotoBrowser/KSPhotoItem.h>
#import <KSPhotoBrowser/KSPhotoBrowser.h>

@interface PhotosViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL searchActive;
@property BOOL resetSearch;
@property NSString* searchText;


@end

@implementation PhotosViewController

NSMutableArray *flickrPhotos;
NSMutableArray * filteredPhotos;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [FlickrManager.sharedManager setFlickerDelegate:self];
    [FlickrManager.sharedManager startFetching];
    
}

// MARK:- Helper Methods

- (void)setupUI {
    self.searchText = @"";
    flickrPhotos = [[NSMutableArray alloc] init];
    filteredPhotos = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Flicker Photos";

}

- (void)sendSearchRequest {
    if( [self.searchText length]  == 0 ) {
        self.searchActive = NO;
    }else{
        
        // stop current recent photos fetchings
        [FlickrManager.sharedManager stopFetchingAndDownload];
        // start fetching for specific search text
        [FlickrManager.sharedManager fetchPhotosForSearchWith:self.searchText];
        self.searchActive = YES;
    }
    
    // search on searchText
    [self.tableView reloadData];
}

// MARK:- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchActive) {
        return [filteredPhotos count];
    }
     return [flickrPhotos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"FlickrPhotoCell";
    FlickrPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FlickrPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Photo* currentPhoto =  (self.searchActive) ? [filteredPhotos objectAtIndex:indexPath.row] : [flickrPhotos objectAtIndex:indexPath.row];
    
   
    [cell.flickerImage sd_setImageWithURL:currentPhoto.url];
    cell.nameLabel.text = currentPhoto.title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
 
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake( 0, 0,  self.tableView.frame.size.width  ,  44);
   return spinner;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

// MARK:- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Photo* selectedPhoto =  (self.searchActive) ? [filteredPhotos objectAtIndex:indexPath.row] : [flickrPhotos objectAtIndex:indexPath.row];
    // get cached image if exists
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:selectedPhoto.url];
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
    // items array to show ... just 1 item
    NSMutableArray *items = @[].mutableCopy;
    KSPhotoItem *item = [KSPhotoItem itemWithSourceView:[[UIImageView alloc] initWithImage:cachedImage] imageUrl:[NSURL URLWithString:selectedPhoto.url.absoluteString]];
    [items addObject:item];
    // show using KSPhotoBrowser
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:0];
    [browser showFromViewController:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // At the bottom...
    if (self.searchActive) {
        if (indexPath.row == filteredPhotos.count -1 ) {
            [self sendSearchRequest];
        }
    }else{
        if (indexPath.row == flickrPhotos.count -1 ) {
            [FlickrManager.sharedManager makeNextPhotoRequest ];
        }
    }
}

// MARK:- UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
     self.searchActive = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"current search text : %@", searchBar.text);
    if( [searchBar.text length]  == 0 || [[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0  ) {
        self.searchActive = NO;
    }else{
        // stop current recent photos fetchings
        [FlickrManager.sharedManager stopFetchingAndDownload];
        // start fetching for specific search text
        [FlickrManager.sharedManager fetchPhotosForSearchWith:searchBar.text];
        self.searchActive = YES;
    }
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
 
    self.searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.resetSearch = YES;
    // to limit network activity, reload half a second after last key press.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendSearchRequest) object:nil];
    [self performSelector:@selector(sendSearchRequest) withObject:nil afterDelay:0.5];
}


// MARK:- FlickrProtocol

- (void)onFetchingPhotosSuccess:(NSMutableArray *)photos {
    
    if (self.searchActive) {
        if( self.resetSearch) {
            filteredPhotos = photos;
        }else{
            [filteredPhotos addObjectsFromArray: [NSArray arrayWithArray:photos]];
        }
        self.resetSearch = NO;
    }else{
        [flickrPhotos addObjectsFromArray: [NSArray arrayWithArray:photos]];
    }
    [self.tableView reloadData];
}

@end
