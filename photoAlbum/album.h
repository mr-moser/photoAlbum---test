//
//  album.h
//  photoAlbum
//
//  Created by Admin on 03.04.14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface album : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageForAlbum;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *dateCreate;

- (id) initAlbum:(NSString*)nameAlbum;
- (id) initWithDictionary:(NSDictionary*)albumDictionary;
- (NSDictionary*) convertToDictionary;

@end
