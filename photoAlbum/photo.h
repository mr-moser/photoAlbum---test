//
//  photo.h
//  photoAlbum
//
//  Created by moser on 4/5/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface photo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *dateCreate;
@property (strong, nonatomic) NSString *forAlbum;

- (id) initPhoto:(NSString*)namePhoto forAlbum:(NSString*)_forAlbum;
- (id) initWithDictionary:(NSDictionary*)photoDictionary forAlbum:(NSString*)_forAlbum;
- (NSDictionary*) convertToDictionary;

@end
