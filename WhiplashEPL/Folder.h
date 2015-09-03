//
//  Folder.h
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Folder : NSMenuItem <NSCoding> {
    NSArray *_fileTypes;
    NSString *_url;
}

@property (nonatomic, strong) NSArray *fileTypes;
@property (nonatomic, strong) NSString *url;

-(instancetype)initWithFiletypes:(NSArray*)filetypes andFolderPath:(NSString*)url;

-(NSString*)fullPath;
-(void)addToMenu:(NSMenu*)menu;

@end
