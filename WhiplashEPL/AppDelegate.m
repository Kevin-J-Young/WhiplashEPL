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
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"W"];
    [self.statusItem setHighlightMode:YES];
    
    self.printManager = [[PrintManager alloc] init];
    [self generatePrinterMenu:self.printerMenu withDebug:YES andDefault:@"zebra"];
    
    self.folderWatcher = [[FolderWatcher alloc] init];
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
        
//        [self showNotificationWithTitle:@"new Download Folder" andDetails:self.folderPath];
        
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
