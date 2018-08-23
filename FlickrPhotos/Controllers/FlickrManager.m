//
//  FlickrManager.m
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 8/22/18.
//  Copyright © 2018 none. All rights reserved.
//

#import "FlickrManager.h"
#import "Photo.h"

@implementation FlickrManager 

NSString *const OFSampleAppAPIKey = @"67ac40e8f2d70f38a4ee9dd473d754cd";
NSString *const OFSampleAppAPISharedSecret = @"615d82121e329306";

@synthesize delegate;

+ (id)sharedManager {
    static FlickrManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        // initialization
        self.flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OFSampleAppAPIKey sharedSecret:OFSampleAppAPISharedSecret];
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)setFlickerDelegate:(id <FlickrProtocol>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)stopFetchingAndDownload {
    
    [self.fetchTimer invalidate];
    
    [self.flickrRequest cancel];
    self.flickrRequest = nil;
    
    [self.imageDownloadTask cancel];
    self.imageDownloadTask = nil;
}

- (void)startFetching {
    
    self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    [self makeNextPhotoRequest];
    
}


// MARK:- Flickr API Methods

- (void)makeNextPhotoRequest {
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    self.flickrRequest.delegate = self;
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:@{@"per_page": @"15"}];
}


- (void) fetchPhotosForSearchWith:(NSString*) text {
    NSString* escapedSearchText = [text stringByAddingPercentEncodingWithAllowedCharacters:
     [NSCharacterSet URLHostAllowedCharacterSet]];
    self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    self.flickrRequest.delegate = self;
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:@{@"per_page": @"15" , @"text": escapedSearchText }];
    
}



- (void)handleTimer:(NSTimer *)timer
{
    // NSURLSessionTaskStateRunning is 0, so a non-nil test for imageDownloadTask is needed
    if ([self.flickrRequest isRunning] || (self.imageDownloadTask && self.imageDownloadTask.state == NSURLSessionTaskStateRunning)) {
        return;
    }
    
    [self makeNextPhotoRequest];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)request didCompleteWithResponse:(NSDictionary *)response
{
    NSMutableArray * photos = [[NSMutableArray alloc] init];
    for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
        Photo* currentPhoto = [[Photo alloc] initWithPhotoId:[photoData objectForKey:@"id"] farm:[photoData objectForKey:@"farm"] secret:[photoData objectForKey:@"secret"] server:[photoData objectForKey:@"server"] title:[photoData objectForKey:@"title"] url:[self.flickrContext photoSourceURLFromDictionary:photoData size:OFFlickrLargeSize]];
        [photos addObject:currentPhoto];
    }
    
    if ([delegate respondsToSelector:@selector(onFetchingPhotosSuccess:)] ) {
        [delegate onFetchingPhotosSuccess:photos];
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)request didFailWithError:(NSError *)error{
    self.flickrRequest = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // If image is large, consider creating the image off the main queue
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
    NSError *error;
    BOOL result = [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (!result) {
        NSLog(@"Error removing temp file at: %@, error: %@", location, error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString* currentImageDownloadPercentage = [NSString stringWithFormat:NSLocalizedString(@"Getting image (%llu of %llu KB)", nil), totalBytesWritten / 1024, totalBytesExpectedToWrite / 1024];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        // handle Error
    }
    self.imageDownloadTask = nil;
}


@end
