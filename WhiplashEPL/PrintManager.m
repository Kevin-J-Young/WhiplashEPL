//
//  PrintManager.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "PrintManager.h"


@implementation PrintManager

-(NSArray*)printersAvailable {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/lpstat";
    task.arguments = @[@"-p"];
    task.standardOutput = pipe;
    
    [task launch];
    
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    __block NSMutableArray *printers = [NSMutableArray arrayWithCapacity:5];
    [printers addObject:@"Debug"];
    
    [grepOutput enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSRange range = [line rangeOfString:@"printer "];
        if (range.length > 0) {
            unsigned long start = range.length + range.location;
            NSString *afterPrint = [line substringFromIndex:start];
            NSRange spaceRanger = [afterPrint rangeOfString:@" "];
            [printers addObject:[afterPrint substringToIndex:spaceRanger.location]];
        }
        
    }];
    
    return [printers copy];
}





#pragma mark - debug notifications
-(void)showNotificationWithTitle:(NSString*)title andDetails:(NSString*)details {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = details;
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSLog(@"%@", details);
}


-(void)shellPrint:(NSString*)fullPath {
    if ([self.currentPrinterName isEqualToString:@"Debug"]) {
        [self showNotificationWithTitle:@"PRINT" andDetails:fullPath];
        [self trashFile:fullPath];
    } else {
        NSPipe *pipe = [NSPipe pipe];
        
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/lpr";
        task.arguments = @[@"-P", self.currentPrinterName, @"-lr", fullPath];
        task.standardOutput = pipe;
        task.terminationHandler = ^(NSTask *aTask){
            NSLog(@"Terminating!");
            [self trashFile:fullPath];
            
        };
        
        [task launch];
    }
}

-(void)trashFile:(NSString*)fullPath {
    NSURL *urlPath = [NSURL fileURLWithPath:fullPath isDirectory:NO];
    [[NSFileManager defaultManager] trashItemAtURL:urlPath resultingItemURL:nil error:nil];
}

@end
