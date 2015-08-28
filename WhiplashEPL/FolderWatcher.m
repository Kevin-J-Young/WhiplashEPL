//
//  FolderWatcher.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "FolderWatcher.h"

#import "PrintManager.h"

@implementation FolderWatcher




-(instancetype)init {
    if ([super init]) {
        //read saved preferences here
        if (!self.folderPath) {
            self.folderPath = [self downloadsFolder];
        }
        self.validExtensions = @[@"epl", @"epl2", @"EPL", @"EPL2"];
    }
    return self;
}







-(NSString*)downloadsFolder {
    NSString *downloadsDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        downloadsDirectory = [paths objectAtIndex:0];
    }
    return downloadsDirectory;
}







-(void)start {
//    NSLog(@"start?");
    if (!self.timer.valid) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkFolderStatus) userInfo:nil repeats:YES];
    }
}

-(void)stop {
//    NSLog(@"stop?");
    if (self.timer.valid) {
        [self.timer invalidate];
    }
}















-(void)checkFolderStatus
{
    self.contents =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.folderPath error:nil];
    
    [self performSelectorOnMainThread:@selector(getNewFiles) withObject:self.contents waitUntilDone:YES];
}

-(void)getNewFiles {
    NSMutableArray *newFiles = [self.contents mutableCopy];
    if (self.lastContents) {
        [newFiles removeObjectsInArray:self.lastContents];
    }
    
    if (newFiles.count > 0) {
        [self filterEPL:[newFiles copy]];
    }
    
    self.lastContents = self.contents;
}

-(void)filterEPL:(NSArray*)newFiles {
    [newFiles enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop){
        if ([self.validExtensions containsObject:[filename pathExtension]]) {
            NSString *fullPath = [self.folderPath stringByAppendingPathComponent:filename];
            [self.printer shellPrint:fullPath];
        }
    }];
}





@end
