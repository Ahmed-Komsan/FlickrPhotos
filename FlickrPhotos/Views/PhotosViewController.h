//
//  PhotosViewController.h
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 7/30/18.
//  Copyright © 2018 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrProtocol.h"


@interface PhotosViewController : UIViewController <UITableViewDataSource , UITableViewDelegate , FlickrProtocol , UISearchBarDelegate , UISearchControllerDelegate , UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;

@end
