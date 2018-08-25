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
@property BOOL resetFilteredPhotos;
@property NSString* searchText;

@end

@implementation PhotosViewController

@synthesize searchController;
NSMutableArray *flickrPhotos;
NSMutableArray * filteredPhotos;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [FlickrManager.sharedManager setFlickerDelegate:self];
    [FlickrManager.sharedManager startFetching];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchController dismissViewControllerAnimated:NO completion:nil];
}

// MARK:- Helper Methods

- (void)setupUI {
    self.searchText = @"";
    flickrPhotos = [[NSMutableArray alloc] init];
    filteredPhotos = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Flicker Photos";
    
    // add and setupt UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.navigationItem.searchController = self.searchController;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search Photos";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

- (void)sendSearchRequest {
    if( [self isFiltering] ) {
        // stop current recent photos fetchings
        [FlickrManager.sharedManager stopFetchingAndDownload];
        // start fetching for specific search text
        [FlickrManager.sharedManager fetchPhotosForSearchWith:self.searchText];
    }
}


- (BOOL) isFiltering {
    return searchController.isActive &&  [self searchBarIsEmpty] == NO ;
}

- (BOOL) searchBarIsEmpty {
    // Returns YES if the text is empty or nil
    return [self.searchController.searchBar.text length] == 0 ;
}

// MARK:- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( [self isFiltering] ) {
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
    
    Photo* currentPhoto =  ([self isFiltering]) ? [filteredPhotos objectAtIndex:indexPath.row] : [flickrPhotos objectAtIndex:indexPath.row];
    
   
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
    
    Photo* selectedPhoto =  ([self isFiltering]) ? [filteredPhotos objectAtIndex:indexPath.row] : [flickrPhotos objectAtIndex:indexPath.row];
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
    if ([self isFiltering]) {
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

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    if (searchText) {
        
        if (searchText.length != 0) {
            self.searchText = searchText;
            self.resetFilteredPhotos = YES;
            // to limit network activity, reload a second after last key press.
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendSearchRequest) object:nil];
            [self performSelector:@selector(sendSearchRequest) withObject:nil afterDelay:1.0];
            
        }
        else {
            filteredPhotos = flickrPhotos;
        }
        
        [self.tableView reloadData];
    }
}


// MARK:- FlickrProtocol

- (void)onFetchingPhotosSuccess:(NSMutableArray *)photos {
    
    if ([self isFiltering]) {
        if( self.resetFilteredPhotos) {
            filteredPhotos = photos;
        }else{
            [filteredPhotos addObjectsFromArray: [NSArray arrayWithArray:photos]];
        }
        self.resetFilteredPhotos = NO;
    }else{
        [flickrPhotos addObjectsFromArray: [NSArray arrayWithArray:photos]];
    }
    [self.tableView reloadData];
}

@end
