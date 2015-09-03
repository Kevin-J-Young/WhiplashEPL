//
//  FolderWatcher.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "FolderWatcher.h"

#import "PrintManager.h"
#import "Folder.h"
#import "FileType.h"
#import "FileManager.h"

@implementation FolderWatcher
@synthesize timer = _timer;

+(FolderWatcher*)sharedInstance
{
    static FolderWatcher *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FolderWatcher alloc] init];
    });
    return _sharedInstance;
}



-(BOOL)isRunning {
    return self.timer.valid;
}

-(NSString*)nextToggleState {
    if (self.timer.valid) {
        return @"Stop";
    } else {
        return @"Start";
    }
}


-(void)start {
    if (!self.timer.valid) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(checkFolderStatus) userInfo:nil repeats:YES];
    }
}

-(void)stop {
    if (self.timer.valid) {
        [self.timer invalidate];
    }
}















-(void)checkFolderStatus
{
    NSLog(@"checking...");
    [[[FileManager sharedInstance] watchedFolders] enumerateObjectsUsingBlock:^(Folder *folder, NSUInteger idx, BOOL *stop) {
        
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder.fullPath error:nil];
//        NSLog(@"%@>> %d items", folder.fullPath, contents.count);
        [folder.fileTypes enumerateObjectsUsingBlock:^(FileType *filetype, NSUInteger idx, BOOL *stop) {
            [contents enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop){
                if ([filetype.fileExtensionList containsObject:[filename pathExtension]]) {
                    NSString *fullPath = [folder.fullPath stringByAppendingPathComponent:filename];
                    [[PrintManager sharedInstance] sendFile:fullPath toPrinter:filetype.printerName];
                }
            }];
        }];
    }];
}

@end
