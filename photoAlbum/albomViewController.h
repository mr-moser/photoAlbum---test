//
//  ViewController.h
//  photoAlbum
//
//  Created by moser on 4/2/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "FXImageView.h"
#import "mySingleton.h"
#import "photoViewController.h"
#import "album.h"
#import "QBPopupMenu.h"

@interface albomViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, strong) mySingleton *singleton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *styleButton;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;

- (IBAction)insertItem;
- (IBAction)removeItem;
- (IBAction)showPopupMenu:(id)sender;

@end
