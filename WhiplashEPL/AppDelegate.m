//
//  AppDelegate.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "AppDelegate.h"

#import "PrintManager.h"
#import "FolderWatcher.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (unsafe_unretained) IBOutlet NSMenu *printerMenu;

@property (nonatomic, strong) PrintManager *printManager;
@property (nonatomic, strong) FolderWatcher *folderWatcher;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self setupMenu];
    
    if (self.folderWatcher.folderPath && self.printManager.currentPrinterName)  {
        self.folderWatcher.printer = self.printManager;
        [self.folderWatcher start];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
#pragma mark end standard AppDelegate stuff















-(void)setupMenu {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
//    [self.statusItem setTitle:@"W"];
    [self.statusItem setImage:[NSImage imageNamed:@"barIcon"]];
    [self.statusItem setHighlightMode:YES];
    
    self.printManager = [[PrintManager alloc] init];
    [self generatePrinterMenu:self.printerMenu];
    [self chooseDefaultPrinter];
    
    self.folderWatcher = [[FolderWatcher alloc] init];
}


-(void)generatePrinterMenu:(NSMenu*)menu {
    //get list of printers and make menu-items for them
    NSArray *printers = [self.printManager printersAvailable];
    [printers enumerateObjectsUsingBlock:^(NSString *printerName, NSUInteger idx, BOOL *stop) {
        [menu addItemWithTitle:printerName
                                           action:@selector(changeCurrentPrinterTo:)
                                    keyEquivalent:@""];
    }];
}


-(void)changeCurrentPrinterTo:(NSMenuItem*)sender {
    //change Active Printer
    self.printManager.currentPrinterName = sender.title;
    //save choice for next launch
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:@"chosenPrinter"];
    
    //move the checkmark
    [sender.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.title isEqualToString:sender.title]) {
            [item setState:NSOnState];
        } else {
            [item setState:NSOffState];
        }
    }];
}

-(void)chooseDefaultPrinter {
    __block NSMenuItem *chosenMenuItem;
    
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"chosenPrinter"];
    if (saved) {
        [self.printerMenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title isEqualToString:saved]) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we couldn't find a printer matched saved preferences, look for a zebra
    if (!chosenMenuItem) {
        [self.printerMenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:@"zebra" options:NSCaseInsensitiveSearch].length>0) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we couldn't find any zebra, choose debug
    if (!chosenMenuItem) {
        [self.printerMenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:@"debug" options:NSCaseInsensitiveSearch].length>0) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we still can't find anything, just choose the top of the list
    if (!chosenMenuItem) {
        chosenMenuItem = self.printerMenu.itemArray.firstObject;
    }
    
    [self changeCurrentPrinterTo:chosenMenuItem];
}





- (IBAction)chooseFolder:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Disable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setPrompt:@"Select"];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSModalResponseOK )
    {
        // Get directory selected
        NSURL* dir = [openDlg URLs].firstObject;
        self.folderWatcher.folderPath = [dir path];
        [[NSUserDefaults standardUserDefaults] setObject:[dir path] forKey:@"watchFolder"];
    }
}





- (IBAction)startStop:(NSMenuItem*)sender {
    if ([sender.title isEqualToString:@"Start"]) {
        [self.folderWatcher start];
        [sender setTitle:@"Stop"];
    } else {
        [self.folderWatcher stop];
        [sender setTitle:@"Start"];
    }
}


@end
