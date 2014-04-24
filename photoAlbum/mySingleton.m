//
//  mySingleton.m
//  photoAlbum
//
//  Created by moser on 4/2/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import "mySingleton.h"

#define showSaveAlbumAlert 1
#define showInfoErrorAlbumAlert 2
#define showDeleteAlbumAlert 3
#define showSavePhotoAlert 4
#define showInfoErrorPhotoAlert 5
#define showDeletePhotoAlert 6
#define loadAlbumType @"album"
#define loadPhotoType @"photo"

@implementation mySingleton

@synthesize albumArray, photoArray, currentAlbum, currentPhoto, currentPhotoArray, currentAction, viewStyle, saveButtonForPhoto;

//======================================================================================================================
//Создание объекта mySingleton
//======================================================================================================================
static mySingleton *sMySingleton = nil;
+ (mySingleton *) sharedInstance {
    @synchronized(self) {
        if (sMySingleton == nil) {
            sMySingleton = [[mySingleton alloc] init];
        }
    }
    return sMySingleton;
}
//======================================================================================================================
//======================================================================================================================
- (id) init {
    self = [super init];
    if (self) {
        [self saveImageDefault:@"defaultImageForAlbum.jpg"];
        albumArray = [NSMutableArray array];
        photoArray = [NSMutableArray array];
        currentPhotoArray = [NSMutableArray array];
        viewStyle = 0;
        
        [self loadFromPlist:loadAlbumType];
        [self loadFromPlist:loadPhotoType];
        
        //========= ПОДПИСКА НА СОБЫТИЕ ПРИ "СВОРАЧИВАНИИ" ПРИЛОЖЕНИЯ
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:app];
    }
    return self;
}
//======================================================================================================================
//Вставка нового элемента
//======================================================================================================================
- (void)insertItem { //сохранение альбома - запрос названия
    [self showAlert:showSaveAlbumAlert]; //запускаем запрос для имени альбома
}
- (void)insertItemConfirm:(NSString*)nameAlbum { //сохранение альбома - запрос названия
    album *newAlbum = [[album alloc] initAlbum:nameAlbum]; //создаём альбом
    //[newAlbum setImage:image]; //записываем альбому картинку
    [newAlbum setImageForAlbum:@"defaultImageForAlbum.jpg"];
    
    NSInteger index = MAX(0, carousel.currentItemIndex); //получаем индекс текущего альбома
    [albumArray insertObject:newAlbum atIndex:index]; //записываем в массив альбомов созданный альбом
    [carousel insertItemAtIndex:index animated:YES]; //вставляем с анимацией
    
    if (carousel.numberOfItems) { //вызов оповещения о включении кнопки удаления альбома
        [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDelete" object:@(TRUE)]; 
    }
}
//======================================================================================================================
//Удаление элемента
//======================================================================================================================
- (void)removeItem { //удаление альбома
    [self showAlert:showDeleteAlbumAlert]; //запускаем запрос подтверждения
}
- (void)removeItemConfirm { //удаление альбома при подтверждении
    NSInteger index = carousel.currentItemIndex; //получаем индекс текущего альбома
    currentAlbum = [[albumArray objectAtIndex:index] name];
    if (carousel.numberOfItems > 0) {
        NSString *nameForDeleteImage;
        for (int i = 0; i < [photoArray count]; i++) { //удаление всех фотографий из удаляемого альбома
            if ([[[photoArray objectAtIndex:i] forAlbum] isEqualToString:currentAlbum]) {
                nameForDeleteImage = [NSString stringWithFormat:@"%@.jpg", [[photoArray objectAtIndex:i] name]];
                [self removeImageFullAlbum: nameForDeleteImage];
            }
        }
        NSMutableIndexSet* indexes = [[NSMutableIndexSet alloc]init]; //установка indexex для все индексов под удаление
        for (int i = 0; i < [photoArray count]; i++) { //удаление всех фотографий из общего массива фотографий
            if ([[[photoArray objectAtIndex:i] forAlbum] isEqualToString:currentAlbum]) {
                [indexes addIndex:i]; // запись всех индексов для удаление
            }
        }
        [photoArray removeObjectsAtIndexes:indexes]; // удаление всех записанных индексов

        [albumArray removeObjectAtIndex:index]; //удаляем из массива альбомов выбранный альбом
        [carousel removeItemAtIndex:index animated:YES]; //удаляем с анимацией
    }
    if (!carousel.numberOfItems) { //вызов оповещения о выключении кнопки удаления альбома
       [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDelete" object:@(FALSE)];
    }
}
//======================================================================================================================
//Всплывающее окошко создания и удаления альбома
//======================================================================================================================
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex { //метод обработки информации из алерта
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) { //если стиль алерта с тектсовым полем
        UITextField *textField = [alertView textFieldAtIndex:0]; //запись значения из текстового поля алерта
        if ([textField.text isEqualToString:@""]) { //проверка, не пустое ли текстовое поле
            [self showAlert:showInfoErrorAlbumAlert]; //если поле пустое, вывод информации о ошибке
            if (!carousel.numberOfItems) //вызов оповещения о выключении кнопки удаления альбома
                [[NSNotificationCenter defaultCenter] postNotificationName:@"buttonDelete" object:@(FALSE)];
        } else {
            switch (currentAction) {
                case showSaveAlbumAlert:
                    [self insertItemConfirm:textField.text]; //если текстовое поле не пустое, создаём новый альбом с названием из текстового поля
                    break;
                case showSavePhotoAlert:
                    [self saveImageConfirm:textField.text]; //если текстовое поле не пустое, сохраняем фотографию с названием из текстового поля
                    break;
            }
        }
    }
    if (buttonIndex == 1) { //если нажата кнопка Отмена при удалении
        switch (currentAction) {
            case showDeleteAlbumAlert:
                [self removeItemConfirm]; //удаление альбома
                break;
            case showDeletePhotoAlert:
                [self deleteCurrentPhotoConfirm]; //удаление фотографии
                break;
        }
    }
}
- (void) showAlert:(int)type {
    NSString *alertTitle, *alertMessege, *alertButtonTitles, *alertButtonTitles2; //переменные для окна сообщения
    UIAlertViewStyle style; //стиль всплывающего окна
    switch (type) { //проверка типа #define (#define showSaveAlert 1 #define showInfoAlert 2)
        case showSaveAlbumAlert: { //если showSaveAlbumAlert
            currentAction = showSaveAlbumAlert;
            alertTitle = @"Создание нового альбома"; //запись значений переменных
            alertMessege = @"Введите название альбома";
            alertButtonTitles = @"Создать";
            style = UIAlertViewStylePlainTextInput; //определение стиля окна - с текстовым полем
        }
            break;
        case showInfoErrorAlbumAlert: { //если showInfoErrorAlbumAlert
            currentAction = showInfoErrorAlbumAlert;
            alertTitle = @"Ошибка"; //запись значений переменных
            alertMessege = @"Название не может быть пустым";
            alertButtonTitles = @"Ок";
            style = UIAlertViewStyleDefault; //определение стиля окна - просто информация
        }
            break;
        case showDeleteAlbumAlert: { //если showDeleteAlbumAlert
            currentAction = showDeleteAlbumAlert;
            alertTitle = @"Удаление альбома"; //запись значений переменных
            alertMessege = @"Вы действительно хотите удалить этот альбом и всё его содержимое?";
            alertButtonTitles = @"Отмена";
            alertButtonTitles2 = @"Удалить";
            style = UIAlertViewStyleDefault; //определение стиля окна - просто информация
        }
            break;
        case showSavePhotoAlert: { //если showSavePhotoAlert
            currentAction = showSavePhotoAlert;
            alertTitle = @"Сохранение фотографии"; //запись значений переменных
            alertMessege = @"Введите название для фотографии";
            alertButtonTitles = @"Сохранить";
            style = UIAlertViewStylePlainTextInput; //определение стиля окна - с текстовым полем
        }
            break;
        case showDeletePhotoAlert: { //если showDeletePhotoAlert
            currentAction = showDeletePhotoAlert;
            alertTitle = @"Удаление фотографии"; //запись значений переменных
            alertMessege = @"Вы действительно хотите удалить эту фотографию?";
            alertButtonTitles = @"Отмена";
            alertButtonTitles2 = @"Удалить";
            style = UIAlertViewStyleDefault; //определение стиля окна - с текстовым полем
        }
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle //определение всплывающего окна с переменными
                                                        message:alertMessege
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:alertButtonTitles, alertButtonTitles2, nil];
    alertView.alertViewStyle = style; //определение стиля окна
    [alertView show]; //вывод алерта на экран
}
//======================================================================================================================
//Работа с файлами jpg
//======================================================================================================================
- (void)saveImage:(UIImage*)_image andSaveButton:(UIButton*)but {
    [self showAlert:showSavePhotoAlert]; //запускаем запрос подтверждения
    imageForPhoto = _image;
    saveButtonForPhoto = but;
}
- (void)saveImageConfirm:(NSString*)imageName {
    [saveButtonForPhoto setEnabled:FALSE];
    if (imageForPhoto != nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *nameForImage = [NSString stringWithFormat:@"%@.jpg", imageName];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:nameForImage];
        NSData* data = UIImageJPEGRepresentation(imageForPhoto, 1.0);
        [data writeToFile:path atomically:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"offSelectedImageView" object:@(FALSE)];
    
    for (int i = 0; i < [photoArray count]; i++) { //после сохранения обновляем массив картинок для текущего альбома
        photo *tempPhoto = [photoArray objectAtIndex:i];
        if ([[tempPhoto forAlbum] isEqual: currentAlbum]) {
            [currentPhotoArray addObject:tempPhoto];
        }
    }
    
    photo *newPhoto = [[photo alloc] initPhoto:imageName forAlbum:currentAlbum];
    [photoArray addObject:newPhoto];
    
    NSInteger index = MAX(0, carousel.currentItemIndex); //получаем индекс текущей фотографии
    [currentPhotoArray insertObject:newPhoto atIndex:index]; //записываем в массив фотографий созданную фотографию
    
    [carousel insertItemAtIndex:index animated:YES]; //вставляем с анимацией
}
- (UIImage*)loadImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    UIImage* _image = [UIImage imageWithContentsOfFile:path];
    return _image;
}
- (void) deleteCurrentPhoto {
    [self showAlert:showDeletePhotoAlert];
}
- (void) deleteCurrentPhotoConfirm {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"offButtons" object:@(FALSE)];
    NSInteger index = MAX(0, carousel.currentItemIndex); //получаем индекс текущей фотографии
    NSString *namePhotoForDel = [NSString stringWithFormat:@"%@.jpg", [[currentPhotoArray objectAtIndex:index] name]]; //узнаём имя фотографии для удаления
    [self removeImage:namePhotoForDel]; //удаляем сам файл картинки
    int ind = [photoArray indexOfObject:[currentPhotoArray objectAtIndex:index]]; //узнаём индекс этой фотки в главном масссиве всех фотографий
    [photoArray removeObjectAtIndex:ind]; //удаляем эту фотку из главного массива
    [currentPhotoArray removeObjectAtIndex:index]; //удаляем эту фотку из массива выбранного альбома
    [carousel removeItemAtIndex:index animated:YES]; //удаляем с экрана с анимацией
}
- (void)removeImageFullAlbum:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
}
- (void)removeImage:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Поздравляю" message:@"Удаление прошло успешно" delegate:self cancelButtonTitle:@"Прекрасно" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    else {
        NSLog(@"Ошибка удаления файла -:%@ ",[error localizedDescription]);
    }
}
- (void)applyImageForAlbum {
    NSInteger index = MAX(0, carousel.currentItemIndex);
    currentPhoto = [[currentPhotoArray objectAtIndex:index] name];
    for (int i = 0; i < [albumArray count]; i++) {
        if ([[[albumArray objectAtIndex:i] name] isEqualToString:currentAlbum]) {
            [[albumArray objectAtIndex:i] setImageForAlbum:[NSString stringWithFormat:@"%@.jpg", currentPhoto]]; //индекс альбома и устанавливаем выбранную фотографию как обложку альбома
        }
    }
}
- (void)saveImageDefault:(NSString*)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:imageName];
    UIImage *_image = [UIImage imageNamed:imageName];
    NSData* data = UIImageJPEGRepresentation(_image, 1.0);
    [data writeToFile:path atomically:YES];
}
//======================================================================================================================
//Работа с файлами plist
//======================================================================================================================
- (void)applicationWillResignActive:(NSNotification *)notification {
    [self saveToPlist:loadAlbumType];
    [self saveToPlist:loadPhotoType];
}
- (NSString *)dataFilePath:(NSString*)type {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([type isEqual: loadAlbumType]) {
        return [documentsDirectory stringByAppendingPathComponent:@"albomData.plist"];
    }
    else if ([type isEqual: loadPhotoType]) {
        return [documentsDirectory stringByAppendingPathComponent:@"photoData.plist"];
    }
    return nil;
}
-(void)saveToPlist:(NSString*)type { //сохранение файлов plist
    NSMutableArray *arrayForSave; //массив для сохранения
    NSString *filePath; //будущий путь к файлу
    if ([type isEqual: loadAlbumType]) {
        arrayForSave = [[NSMutableArray alloc] initWithCapacity:[albumArray count]]; //создать массив NSArray состоящий из экземпляров NSDictionary
        for (int i = 0; i < [albumArray count]; i++) { //добавляем в arrayForSave экземпляры NSDictionary
            album *newAlbum = (album*)[albumArray objectAtIndex:i]; //получаем объект альбома
            NSDictionary* aDict = [newAlbum convertToDictionary]; //конвертируем в NSDictionary для записи
            [arrayForSave addObject:aDict]; //добавляем в массив для записи
        }
        filePath = [self dataFilePath:loadAlbumType]; //получаем путь к файлу
    }
    else if ([type isEqual: loadPhotoType]) {
        arrayForSave = [[NSMutableArray alloc] initWithCapacity:[photoArray count]]; //создать массив NSArray состоящий из экземпляров NSDictionary
        for (int i = 0; i < [photoArray count]; i++) { //добавляем в arrayForSave экземпляры NSDictionary
            photo *newPhoto = (photo*)[photoArray objectAtIndex:i]; //получаем объект фотографии
            NSDictionary* pDict = [newPhoto convertToDictionary]; //конвертируем в NSDictionary для записи
            [arrayForSave addObject:pDict]; //добавляем в массив для записи
        }
        filePath = [self dataFilePath:loadPhotoType]; //получаем путь к файлу
    }
    [arrayForSave writeToFile:filePath atomically:YES]; //записать этот массив в файл
}
-(void)loadFromPlist:(NSString*)type { //загрузка из файла plist
    NSString *filePath; //будущий путь к файлу
    if ([type isEqual: loadAlbumType]) {
        filePath = [self dataFilePath:loadAlbumType]; //получаем путь к файлу
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { //проверка: если файл существует
            NSArray *arrayFromFile = [[NSArray alloc] initWithContentsOfFile:filePath]; //считать массив словарей из файла
            for (int i = 0; i < arrayFromFile.count; i++) { //перебирая массив
                NSDictionary* aDict = (NSDictionary*)[arrayFromFile objectAtIndex:i]; //считываем словарь, как элемент массива
                album *newAlbum = [[album alloc] initWithDictionary:aDict]; //перегнать все NSDictionary в Album
                [newAlbum setImage:image]; //установить картинку для альбома
                [albumArray addObject:newAlbum]; //добавить newAlbum в массив альбомов
            }
        }
    }
    else if ([type isEqual: loadPhotoType]) {
        filePath = [self dataFilePath:loadPhotoType]; //получаем путь к файлу
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { //проверка: если файл существует
            NSArray *arrayFromFile = [[NSArray alloc] initWithContentsOfFile:filePath]; //считать массив словарей из файла
            for (int i = 0; i < arrayFromFile.count; i++) { //перебирая массив
                NSDictionary* pDict = (NSDictionary*)[arrayFromFile objectAtIndex:i]; //считываем словарь, как элемент массива
                photo *newPhoto = [[photo alloc] initWithDictionary:pDict forAlbum:currentAlbum]; //перегнать все NSDictionary в Photo
                //if ([[newPhoto forAlbum] isEqual: currentAlbum])
                [photoArray addObject:newPhoto]; //добавить newAlbum в массив альбомов
            }
        }
    }
}
//======================================================================================================================
//Создание всплывающего меню для изменения стиля
//======================================================================================================================
-(QBPopupMenu*)createPopUpMenu:(iCarousel*)_carousel {
    carousel = _carousel; //записываем переданную карусель в текущую карусель этого объекта
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] init];
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:@"1" target:self action:@selector(changeStyle:)];
    item1.width = 35;
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"2" target:self action:@selector(changeStyle:)];
    item2.width = 35;
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"3" target:self action:@selector(changeStyle:)];
    item3.width = 35;
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"4" target:self action:@selector(changeStyle:)];
    item4.width = 35;
    QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithTitle:@"5" target:self action:@selector(changeStyle:)];
    item5.width = 35;
    popupMenu.items = [NSArray arrayWithObjects:item1, item2, item3, item4, item5, nil];
    return popupMenu;
}
- (void)changeStyle:(id)sender {
    viewStyle = [[sender title] intValue];
    [self changeStyleConfirm];
}
- (void)changeStyleConfirm {
    switch (viewStyle) {
        case 1: carousel.type = iCarouselTypeLinear; break;
        case 2: carousel.type = iCarouselTypeRotary; break;
        case 3: carousel.type = iCarouselTypeCylinder; break;
        case 4: carousel.type = iCarouselTypeCoverFlow; break;
        case 5: carousel.type = iCarouselTypeTimeMachine; break;
    }
}
//======================================================================================================================
//Создание надписи на картинке
//======================================================================================================================
//-(UIImage *)addText:(UIImage *)img text:(NSString *)text1{
//    int w = img.size.width;
//    int h = img.size.height;
//    //lon = h - lon;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1);
//	
//    char* text	= (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
//    CGContextSelectFont(context, "Arial", 50, kCGEncodingMacRoman);
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
//    
//    //rotate text4
//    CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( 0 ));
//	
//    CGContextShowTextAtPoint(context, 50, 52, text, strlen(text));
//	
//	
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//	
//    return [UIImage imageWithCGImage:imageMasked];
//}
//======================================================================================================================
//======================================================================================================================
@end
