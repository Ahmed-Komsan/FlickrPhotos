//
//  FlickrProtocol.h
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 8/22/18.
//  Copyright © 2018 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlickrProtocol <NSObject>

@optional
- (void) onFetchingPhotosSuccess:(NSMutableArray *) photos;

@end
