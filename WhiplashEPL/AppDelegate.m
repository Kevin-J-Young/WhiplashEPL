//
//  AppDelegate.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "AppDelegate.h"

#import "PrintManager.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (unsafe_unretained) IBOutlet NSMenu *printerMenu;

@property (nonatomic, strong) PrintManager *printManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self setupMenu];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)setupMenu {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"W"];
    [self.statusItem setHighlightMode:YES];
    
    self.printManager = [[PrintManager alloc] init];
    [self generatePrinterMenu:self.printerMenu withDebug:YES andDefault:@"zebra"];
}


-(void)generatePrinterMenu:(NSMenu*)menu withDebug:(BOOL)debug andDefault:(NSString*)defaultName {
    // add debug menu-item and choose it
    if (debug) {
        NSMenuItem *item = [menu addItemWithTitle:@"Debug"
                                           action:@selector(changeCurrentPrinter:)
                                    keyEquivalent:@""];
        [self changeCurrentPrinter:item];
    }
    
    //get list of printers and make menu-items for them
    NSArray *printers = [self.printManager printersAvailable];
    [printers enumerateObjectsUsingBlock:^(NSString *printerName, NSUInteger idx, BOOL *stop) {
        NSMenuItem *item = [menu addItemWithTitle:printerName
                                           action:@selector(changeCurrentPrinter:)
                                    keyEquivalent:@""];
        if (defaultName && [printerName rangeOfString:defaultName options:NSCaseInsensitiveSearch].length>0) {
            [self changeCurrentPrinter:item];
        }
    }];
}


-(void)changeCurrentPrinter:(NSMenuItem*)sender {
    //change Active Printer
    self.printManager.currentPrinterName = sender.title;
    
    //move the checkmark
    [sender.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setState:NSOffState];
    }];
    [sender setState:NSOnState];
}


@end
