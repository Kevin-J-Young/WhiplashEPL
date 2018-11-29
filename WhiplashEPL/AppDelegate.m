//
//  AppDelegate.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "AppDelegate.h"

#import "PFMoveApplication.h"
#import "LoginItem.h"
#import "FileManager.h"
#import "FolderWatcher.h"

#import "Folder.h"

@interface AppDelegate () 

@property (strong, nonatomic) NSStatusItem *statusItem;

@end



@implementation AppDelegate
@synthesize statusItem = _statusItem;


-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    PFMoveToApplicationsFolderIfNecessary();
    [[[LoginItem alloc] init] addAppAsLoginItem];
    
    NSLog(@"move & autorun complete");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [[FileManager sharedInstance] deletePreferences];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunchComplete"]) {
        NSLog(@"loading preferences..");
        [[FileManager sharedInstance] loadPreferences];
        NSLog(@"preferences loaded");
    } else {
        NSLog(@"first launch..");
        [[FileManager sharedInstance] buildDefaultPreferences];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunchComplete"];
        NSLog(@"first launch complete");
    }
    
    // build UI
    NSLog(@"building menu..");
    NSMenu *menu = [self buildStatusMenu];
    NSLog(@"populating menu..");
    [self populateMenu:menu];
    
    
    
    
    // start loop
    NSLog(@"about to start watching folder..");
    [[FolderWatcher sharedInstance] start];
    NSLog(@"startup complete");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"quitting..");
    [[FileManager sharedInstance] savePreferences];
}
#pragma mark end standard AppDelegate stuff




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
