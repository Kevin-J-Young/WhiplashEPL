//
//  PrintManager.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "PrintManager.h"

#import "FileManager.h"
@import AppKit;



@implementation PrintManager

+(PrintManager*)sharedInstance
{
    static PrintManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PrintManager alloc] init];
    });
    return _sharedInstance;
}

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
    [printers addObject:@"choose Printer"];
    
    [grepOutput enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSRange range = [line rangeOfString:@"printer "];
        if (range.length > 0 && range.location==0) {
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


-(void)sendFile:(NSString*)filePath toPrinter:(NSString*)printerName {
//    NSString *logStr = [NSString stringWithFormat:@"%@ - %@", filePath, printerName];
//    [[FileManager sharedInstance] writeToLog:logStr];
    
    if ([printerName isEqualToString:@"choose Printer"]) {
        [self showNotificationWithTitle:@"PRINT" andDetails:filePath];
        [self trashFile:filePath];
    } else {
//        NSLog(@"Printing %@ to %@", filePath, printerName);
//        [[FileManager sharedInstance] writeToLog:@"printing now?"];
        NSPipe *pipe = [NSPipe pipe];
        
        NSTask *task = [[NSTask alloc] init];
//        [[FileManager sharedInstance] writeToLog:@"created task"];
        task.launchPath = @"/usr/bin/lpr";
        task.arguments = @[@"-P", printerName, @"-lr", filePath];
        task.standardOutput = pipe;
//        [[FileManager sharedInstance] writeToLog:@"NOT adding termination handler..."];
//        task.terminationHandler = ^(NSTask *aTask){
//            NSLog(@"print job complete, deleting file");
//            [[FileManager sharedInstance] writeToLog:@"print job complete, deleting file?"];
////            [self trashFile:filePath];
//        };
        
        
        
//        [[FileManager sharedInstance] writeToLog:@"about to launch task"];
        [task launch];
//        [[FileManager sharedInstance] writeToLog:@"task launched, waiting.."];
        [task waitUntilExit];
//        [[FileManager sharedInstance] writeToLog:@"task finished"];
        [self trashFile:filePath];
//        [[FileManager sharedInstance] writeToLog:@"trasher returned"];
    }
}

-(void)trashFile:(NSString*)fullPath {
//    [[FileManager sharedInstance] writeToLog:@"trashing?"];
    NSURL *urlPath = [NSURL fileURLWithPath:fullPath isDirectory:NO];
    [[NSWorkspace sharedWorkspace] recycleURLs:@[urlPath] completionHandler:nil];
//    [[FileManager sharedInstance] writeToLog:@"trashed!!!"];
}

@end
