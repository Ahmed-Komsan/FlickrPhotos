//
//  FlickrPhotoCell.h
//  FlickrPhotos
//
//  Created by Ahmed Komsan on 7/30/18.
//  Copyright © 2018 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UIImageView *flickerImage;
    @property (weak, nonatomic) IBOutlet UILabel *nameLabel;
    
@end
