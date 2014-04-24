//
//  ViewController.m
//  photoAlbum
//
//  Created by moser on 4/2/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import "albomViewController.h"

@interface albomViewController ()

@end

@implementation albomViewController

@synthesize carousel, singleton, welcomeLabel, deleteButton, styleButton, bottomToolBar;

- (void)awakeFromNib {
    [super awakeFromNib];
    singleton = [mySingleton sharedInstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self //подписка на событие о включении или выключении кнопки удаления альбома
                                             selector:@selector(buttonDelete:)
                                                 name:@"buttonDelete"
                                               object:nil];
    
    if (![[singleton albumArray] count]) { //проверка, если альбомов нет, показваем приветствие
        [self welcomeLabelShow];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    self.popupMenu = [singleton createPopUpMenu:carousel]; //создание всплавающего меню
    
    if (![singleton viewStyle]) //установка стиля карусели при загрузке
        carousel.type = [singleton viewStyle];
    else
        [singleton changeStyleConfirm];
}

#pragma mark - QBPopupMenu
- (IBAction)showPopupMenu:(id)sender { //вычисление координат кнопки стиля и вызов всплывающего меню с этими координатами
    UIView *view = [sender view];
    CGRect frame = [view convertRect:view.bounds toView:self.view];
    [self.popupMenu showInView:self.view atPoint:CGPointMake(frame.origin.x + 90, frame.origin.y)];
}

-(void)buttonDelete:(NSNotification*)notification {
    BOOL result = [[notification object] boolValue];
    [deleteButton setEnabled: result]; //включение или выключени кнопки удаления
    [styleButton setEnabled: result]; //включение или выключени кнопки стиля
    if (!result) {
        welcomeLabel.text = @"У вас не создано ни одного альбома!\n\nСоздайте альбом с помощью кнопки \"+\"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)welcomeLabelShow {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDelete" object:@(FALSE)];
}

- (IBAction)insertItem {
    [singleton insertItem];
    welcomeLabel.text = @"";
}

- (IBAction)removeItem {
    [singleton removeItem];
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    album *tempAlbum = [[singleton albumArray] objectAtIndex:index]; //получаем индекс текущего альбома
    [singleton setCurrentAlbum:[tempAlbum name]]; //записываем имя текущего альбома в singleton
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]; // Имя вашей storyboard
    photoViewController *testViewController = (photoViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"photoViewController"]; // identifier вам нужно, чтобы был проставлен в Storyboard.
    [self.navigationController pushViewController:testViewController animated:YES];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [[singleton albumArray] count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    UILabel *label = nil;
    album *album = [[singleton albumArray] objectAtIndex:index];
    if (view == nil) {        
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 250.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0 , 200, 200.0f, 50.0f)];
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:1 alpha:1];
        label.font = [label.font fontWithSize:17];
        label.tag = 1;
        [view addSubview:label];
    }
    label.text = [album name];
    ((FXImageView *)view).image = [self loadImage:[album imageForAlbum]];
    return view;
}

- (UIImage*)loadImage:(NSString*)nameImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:nameImage];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (void)viewDidUnload {
    //[self setShowImageView:nil];
    [self setWelcomeLabel:nil];
    [self setDeleteButton:nil];
    [self setStyleButton:nil];
    [self setBottomToolBar:nil];
    [super viewDidUnload];
}

@end
