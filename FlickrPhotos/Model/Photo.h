//
//  Photo.h
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 8/22/18.
//  Copyright © 2018 none. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, strong) NSString* photoId;
@property (nonatomic, strong) NSString* secret;
@property (nonatomic, strong) NSString* farm;
@property (nonatomic, strong) NSString* server;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSURL* url;

- (id)initWithPhotoId:(NSString *)_id
                 farm:(NSString *)_farm
               secret:(NSString *)_secret
               server:(NSString *)_server
                title:(NSString *)_title
                url:(NSURL *)_url;

- (NSURL*) getPhotoUrl;

@end
