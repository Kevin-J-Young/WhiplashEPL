//
//  AppDelegate.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PrintManager;
@class FolderWatcher;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    PrintManager *_printManager;
    NSMenu *_statusMenu;
    NSStatusItem *_statusItem;
    NSMenu *_printerMenu;
    FolderWatcher *_folderWatcher;
}



@end

