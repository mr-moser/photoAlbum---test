//
//  album.m
//  photoAlbum
//
//  Created by Admin on 03.04.14.
//  Copyright (c) 2014 moser. All rights reserved.
//

#import "album.h"

@implementation album

@synthesize image, name, dateCreate, imageForAlbum;

- (id) initAlbum:(NSString*)nameAlbum {
    self = [super init];
    if (self) {
        name = nameAlbum;
        dateCreate = [NSDate date];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)albumDictionary {
    self = [super init];
    if (self) {
        name = [albumDictionary objectForKey:@"name"];
        imageForAlbum = [albumDictionary objectForKey:@"imageForAlbum"];
        dateCreate = [albumDictionary objectForKey:@"dateCreate"];
    }
    return self;
}

- (NSDictionary*)convertToDictionary {
    NSDictionary* albumDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     name, @"name",
                                     imageForAlbum, @"imageForAlbum",
                                     dateCreate, @"dateCreate",
                                     nil];
    return albumDictionary;
}

@end