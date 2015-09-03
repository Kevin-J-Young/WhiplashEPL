//
//  FileType.h
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileType : NSMenuItem <NSCoding> {
    NSArray *_fileExtensionList;
    NSString *_printerName;
}

@property (nonatomic, strong) NSArray *fileExtensionList;
@property (nonatomic, strong) NSString *printerName;

@end
