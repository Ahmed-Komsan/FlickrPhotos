//
//  FlickrManager.h
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 8/22/18.
//  Copyright © 2018 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objectiveflickr/ObjectiveFlickr.h>
#import "FlickrProtocol.h"

@interface FlickrManager : NSObject  <OFFlickrAPIRequestDelegate , NSURLSessionDownloadDelegate>

@property (nonatomic) OFFlickrAPIContext *flickrContext;
@property (nonatomic) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic) NSString *nextPhotoTitle;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSURLSessionDownloadTask *imageDownloadTask;
@property (weak, nonatomic) NSTimer *fetchTimer;
@property (nonatomic, weak) id <FlickrProtocol> delegate;

+ (id)sharedManager;
- (void)stopFetchingAndDownload;
- (void)startFetching;
- (void)setFlickerDelegate:(id <FlickrProtocol>)aDelegate;
- (void)makeNextPhotoRequest;
- (void) fetchPhotosForSearchWith:(NSString*) text;

@end
