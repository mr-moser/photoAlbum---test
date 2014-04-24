//
//  photoViewController.m
//  photoAlbum
//
//  Created by moser on 4/3/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import "photoViewController.h"

@interface photoViewController ()

@end

@implementation photoViewController

@synthesize carousel, singleton, selectedImageView, filterButton, saveButton, deleteButton, styleButton, popupMenu, welcomeLabelPhoto, imageForAlbumButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    singleton = [mySingleton sharedInstance];
    photo *tempPhoto;
    for (int i = 0; i < [[singleton photoArray] count]; i++) {
        tempPhoto = [[singleton photoArray] objectAtIndex:i];
        if ([[tempPhoto forAlbum] isEqual:[singleton currentAlbum]]) {
            [[singleton currentPhotoArray] addObject:tempPhoto];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self //подписка на событие о включении или выключении кнопки удаления альбома
                                             selector:@selector(offButtons:)
                                                 name:@"offButtons"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self //подписка на событие о включении или выключении картинки для загрузки
                                             selector:@selector(offSelectedImageView:)
                                                 name:@"offSelectedImageView"
                                               object:nil];
    if (![[singleton currentPhotoArray] count]) { //проверка, если фотографий в этом альбоме нет, показваем приветствие
        [self welcomeLabelShow];
    }
    else {
        welcomeLabelPhoto.text = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.popupMenu = [singleton createPopUpMenu:carousel]; //создание всплавающего меню
    
    if (![singleton viewStyle]) //установка стиля карусели при загрузке
        carousel.type = [singleton viewStyle];
    else
        [singleton changeStyleConfirm];
}

-(void)offSelectedImageView:(NSNotification*)notification {
    BOOL result = [[notification object] boolValue];
    [selectedImageView setAlpha:result];
    [carousel setAlpha:!result];
}

- (IBAction)deleteCurrentPhoto:(id)sender {
    [singleton deleteCurrentPhoto];
}

-(void)offButtons:(NSNotification*)notification {
    BOOL result = [[notification object] boolValue];
    [deleteButton setEnabled: result]; //включение или выключени кнопки удаления
    [styleButton setEnabled: result]; //включение или выключени кнопки стиля
    [filterButton setEnabled: result]; //включение или выключени кнопки фильтров
    [imageForAlbumButton setEnabled: result]; //включение или выключени кнопки обложки для альбома
    if (!result) {
        welcomeLabelPhoto.text = @"В этом альбоме у вас нет ни одной фотографии!\n\nДобавьте фотографию с помощью кнопки \"+\" или с камеры.";
    }
    else { }
}

- (void)welcomeLabelShow {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"offButtons" object:@(FALSE)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//получение фото из альбома фотографий устройства
- (IBAction)photoFromAlbum {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
//получение фото с камеры
- (IBAction)photoFromCamera {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
//установка картинки в selectedImageView
- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [saveButton setEnabled: true]; //включение кнопки сохранения
    [[NSNotificationCenter defaultCenter] postNotificationName:@"offButtons" object:@(TRUE)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"offSelectedImageView" object:@(TRUE)];
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [selectedImageView setImage:originalImage];
    [photoPicker dismissModalViewControllerAnimated:YES];
}
//сохранение картинки
- (IBAction)saveImageToAlbum {
    [singleton saveImage:self.selectedImageView.image andSaveButton:(UIButton*)saveButton];
}

#pragma mark - QBPopupMenu
- (IBAction)showPopupMenu:(id)sender {
    UIView *view = [sender view];
    CGRect frame = [view convertRect:view.bounds toView:self.view];
    [self.popupMenu showInView:self.view atPoint:CGPointMake(frame.origin.x + 90, frame.origin.y)];
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //UIImage *item = [[singleton photoArray] objectAtIndex:index];
    //[showImageView setImage: item];
    NSLog(@"%d", index);
}

- (IBAction)backButtonPress:(id)sender { //возврат на список альбомов
    [[singleton currentPhotoArray] removeAllObjects];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]; // Имя вашей storyboard
    albomViewController *testViewController = (albomViewController *)[storyboard  instantiateViewControllerWithIdentifier:@"albomViewController"]; // identifier вам нужно, чтобы был проставлен в Storyboard.
    [self.navigationController pushViewController:testViewController animated:YES];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [[singleton currentPhotoArray] count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    welcomeLabelPhoto.text = @"";
    UILabel *label = nil;
    photo *photo = [[singleton currentPhotoArray] objectAtIndex:index];
    if (view == nil) {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, -40, 230.0f, 50.0f)];
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:1 alpha:1];
        label.font = [label.font fontWithSize:17];
        label.tag = 1;
        [view addSubview:label];
    }
    //label.text = [photo name];
    
    NSString *namePhoto = [NSString stringWithFormat:@"%@.jpg", [photo name]];
    ((FXImageView *)view).image = [self loadImage:namePhoto];
    
    return view;
}

- (IBAction)applyImageForAlbum:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Установка обложки" //определение всплывающего окна с переменными
                                                        message:@"Текущая фотография установлена как обложка для альбома"
                                                       delegate:self
                                              cancelButtonTitle:@"Ок"
                                              otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault; //определение стиля окна
    [alertView show]; //вывод алерта на экран
    [singleton applyImageForAlbum];
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
    [self setDeleteButton:nil];
    [self setStyleButton:nil];
    [self setWelcomeLabelPhoto:nil];
    [self setImageForAlbumButton:nil];
    [super viewDidUnload];
}

@end
