//
//  Photo.m
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 8/22/18.
//  Copyright © 2018 none. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize photoId;
@synthesize farm;
@synthesize secret;
@synthesize server;
@synthesize title;
@synthesize url;

- (id)initWithPhotoId:(NSString *)_id
                 farm:(NSString *)_farm
               secret:(NSString *)_secret
               server:(NSString *)_server
                title:(NSString *)_title
                  url:(NSURL *)_url{
    
    
    
    self = [super init];
    if (self)
    {
        self.photoId = _id;
        self.farm = _farm;
        self.secret = _secret;
        self.server = _server;
        self.title = _title;
        self.url = _url;
    }
    return self;
}

- (NSURL*) getPhotoUrl {
   return [[NSURL alloc]initWithString:@"https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg"];
}

@end
