//
//  mySingleton.h
//  photoAlbum
//
//  Created by moser on 4/2/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iCarousel.h"
#import "album.h"
#import "photo.h"
#import "QBPopupMenu.h"

@interface mySingleton : NSObject {
    UIImage *image, *imageForAlbum, *imageForPhoto;
    iCarousel *carousel;
}

@property (strong, nonatomic) NSMutableArray *albumArray;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) NSMutableArray *currentPhotoArray;
@property (strong, nonatomic) NSString *currentAlbum;
@property (strong, nonatomic) NSString *currentPhoto;
@property (nonatomic) int currentAction;
@property (nonatomic) int viewStyle;
@property (weak, nonatomic) UIButton *saveButtonForPhoto;

+ (mySingleton *) sharedInstance;
- (void)insertItem;
- (void)removeItem;
- (QBPopupMenu*)createPopUpMenu:(iCarousel*)_carousel;
- (void)saveImage:(UIImage*)_image andSaveButton:(UIButton*)but ;
- (void)loadFromPlist:(NSString*)type;
- (void)changeStyleConfirm;
- (void)deleteCurrentPhoto;
- (void)applyImageForAlbum;

@end
