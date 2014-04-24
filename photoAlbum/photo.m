//
//  photo.m
//  photoAlbum
//
//  Created by moser on 4/5/14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import "photo.h"

@implementation photo

@synthesize forAlbum, name, dateCreate;

- (id) initPhoto:(NSString*)namePhoto forAlbum:(NSString*)_forAlbum {
    self = [super init];
    if (self) {
        name = namePhoto;
        forAlbum = _forAlbum;
        dateCreate = [NSDate date];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)photoDictionary forAlbum:(NSString*)_forAlbum {
    self = [super init];
    if (self) {
        name = [photoDictionary objectForKey:@"name"];
        forAlbum = [photoDictionary objectForKey:@"forAlbum"];
        dateCreate = [photoDictionary objectForKey:@"dateCreate"];
    }
    return self;
}

- (NSDictionary*)convertToDictionary {
    NSDictionary* photoDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     name, @"name",
                                     dateCreate, @"dateCreate",
                                     forAlbum, @"forAlbum",
                                     nil];
    return photoDictionary;
}

@end
