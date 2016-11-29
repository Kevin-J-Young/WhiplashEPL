//
//  AppDelegate.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "AppDelegate.h"

#import "PFMoveApplication.h"
#import "FileManager.h"
#import "FolderWatcher.h"

#import "Folder.h"

@interface AppDelegate () 

@property (strong, nonatomic) NSStatusItem *statusItem;

@end



@implementation AppDelegate
@synthesize statusItem = _statusItem;


-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSFileManager defaultManager] createFileAtPath:[[FileManager sharedInstance] logPath ] contents:nil attributes:nil];
    [[FileManager sharedInstance] writeToLog:@"\nSTART"];
    [[FileManager sharedInstance] writeToLog:[NSString stringWithFormat:@"foo %f", 4.7]];
//    PFMoveToApplicationsFolderIfNecessary();
//    [self addToLoginItems];
    [[FileManager sharedInstance] writeToLog:@"prep complete"];
    BOOL booboo = WLog(@"param: %@, %@", @"maybe?", @"successs!");
    NSLog(@"%hhd", booboo);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[FileManager sharedInstance] writeToLog:@"launched"];
    [[FileManager sharedInstance] deletePreferences];
    


    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunchComplete"]) {
        [[FileManager sharedInstance] loadPreferences];
    } else {
        [[FileManager sharedInstance] writeToLog:@"first launch"];
        [[FileManager sharedInstance] buildDefaultPreferences];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunchComplete"];
    }
    
    // build UI
    NSMenu *menu = [self buildStatusMenu];
    [self populateMenu:menu];
    
    
    
    
    // start loop
    [[FolderWatcher sharedInstance] start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[FileManager sharedInstance] savePreferences];
}
#pragma mark end standard AppDelegate stuff










-(void)addToLoginItems {
    // Get the path of the app
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSLog(@"%@", bundleURL);
    // Get the list you want to add the path to
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    // Add the item to the list
    LSSharedFileListInsertItemURL(loginItemsListRef, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)bundleURL, NULL, NULL);
}




-(NSMenu*)buildStatusMenu {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"main"];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem setMenu:mainMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"barIcon"]];
    [self.statusItem setHighlightMode:YES];
    
    return mainMenu;
}


-(void)populateMenu:(NSMenu*)menu {
    
        
    NSArray *folders = [[FileManager sharedInstance] watchedFolders];
    [folders enumerateObjectsUsingBlock:^(Folder *folder, NSUInteger idx, BOOL *stop) {
        [folder addToMenu:menu];
    }];
    
    [menu addItem:[NSMenuItem separatorItem]];


    NSMenuItem *toggleItem = [[NSMenuItem alloc] initWithTitle:@"Stop" action:@selector(toggleWatcher:) keyEquivalent:@""];
    [menu addItem:toggleItem];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
}



-(void)toggleWatcher:(NSMenuItem*)sender {
    if ([sender.title isEqualToString:@"Start"]) {
        [[FolderWatcher sharedInstance] start];
    } else {
        [[FolderWatcher sharedInstance] stop];
    }
    [sender setTitle:[[FolderWatcher sharedInstance] nextToggleState]];
}




@end
