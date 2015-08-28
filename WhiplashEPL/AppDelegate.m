//
//  AppDelegate.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"W"];
    [self.statusItem setHighlightMode:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
