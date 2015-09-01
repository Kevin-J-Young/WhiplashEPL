//
//  PrinterMenu.m
//  WhiplashEPL
//
//  Created by Kevin Young on 8/31/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "PrinterMenu.h"

@interface PrinterMenu()
@property (nonatomic, strong, readwrite) NSString *selectedPrinter;
@property (nonatomic, strong, readwrite) NSArray *fileTypes;

@property (nonatomic, strong) NSString *saveKey;
@end

@implementation PrinterMenu

+(PrinterMenu*)menuForFileTypes:(NSArray*)fileTypes preferedPrinter:(NSString*)preferedPrinter {
    PrinterMenu *pm = [[PrinterMenu alloc] initWithTitle:fileTypes.firstObject action:nil keyEquivalent:@""];
    pm.saveKey = [NSString stringWithFormat:@"%@Printer", pm.title];
    [pm buildMenu];
    [pm chooseDefaultPrinterwithPreference:preferedPrinter];
    
    return pm;
}


-(void)buildMenu {
    [self setSubmenu:[[NSMenu alloc] initWithTitle:@""]];
    //get list of printers and make menu-items for them
    NSArray *printers = [self printersAvailable];
    [printers enumerateObjectsUsingBlock:^(NSString *printerName, NSUInteger idx, BOOL *stop) {
        [self.submenu addItemWithTitle:printerName
                        action:@selector(changeCurrentPrinterTo:)
                 keyEquivalent:@""];
    }];
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
    [printers addObject:@"Debug"];
    
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



-(void)changeCurrentPrinterTo:(NSMenuItem*)sender {
    //change Active Printer
    self.selectedPrinter = sender.title;
    //save choice for next launch
    [[NSUserDefaults standardUserDefaults] setObject:sender.title forKey:self.saveKey];
    
    //move the checkmark
    [sender.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.title isEqualToString:sender.title]) {
            [item setState:NSOnState];
        } else {
            [item setState:NSOffState];
        }
    }];
}

-(void)chooseDefaultPrinterwithPreference:(NSString*)preferedPrinter {
    __block NSMenuItem *chosenMenuItem;
    
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:self.saveKey];
    if (saved) {
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title isEqualToString:saved]) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we couldn't find a printer matched saved preferences, look for a zebra
    if (!chosenMenuItem) {
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:preferedPrinter options:NSCaseInsensitiveSearch].length>0) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we couldn't find any zebra, choose debug
    if (!chosenMenuItem) {
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:@"debug" options:NSCaseInsensitiveSearch].length>0) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we still can't find anything, just choose the top of the list
    if (!chosenMenuItem) {
        chosenMenuItem = self.submenu.itemArray.firstObject;
    }
    
    [self changeCurrentPrinterTo:chosenMenuItem];
}


@end
