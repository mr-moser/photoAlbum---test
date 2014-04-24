//
//  photoViewController.h
//  photoAlbum
//
//  Created by moser on 4/3/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "FXImageView.h"
#import "mySingleton.h"
#import "albomViewController.h"
#import "QBPopupMenu.h"
#import "photo.h"

@interface photoViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *originalImage;
}

@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, strong) mySingleton *singleton;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImageView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *filterButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *styleButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabelPhoto;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *imageForAlbumButton;


- (IBAction)photoFromAlbum;
- (IBAction)photoFromCamera;
- (IBAction)applyImageForAlbum:(id)sender;
- (IBAction)saveImageToAlbum;
- (IBAction)backButtonPress:(id)sender;
- (IBAction)showPopupMenu:(id)sender;
- (IBAction)deleteCurrentPhoto:(id)sender;

@end
