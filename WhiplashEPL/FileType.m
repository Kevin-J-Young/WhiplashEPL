//
//  FileType.m
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "FileType.h"
#import "FileManager.h"

#import "PrintManager.h"

@implementation FileType

@synthesize fileExtensionList = _fileExtensionList;
@synthesize printerName = _printerName;


-(NSString*)description {
    return [NSString stringWithFormat:@"%@: %@", self.fileExtensionList, self.printerName];
}

#pragma mark - NSCoding

-(NSString*)title {
    return _fileExtensionList.firstObject;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.fileExtensionList = [decoder decodeObjectForKey:@"fileExtensionList"];
    self.printerName = [decoder decodeObjectForKey:@"printerName"];
    
    [self buildMenuItem];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileExtensionList forKey:@"fileExtensionList"];
    [encoder encodeObject:self.printerName forKey:@"printerName"];
}

-(void)buildMenuItem {
    [self setAction:nil];
    [self setKeyEquivalent:@""];
    [self setSubmenu:[[NSMenu alloc] initWithTitle:self.title]];
    [self generatePrinterMenu:self.submenu];
    NSLog(@"menu built, adding checkmark");
    [self chooseDefaultPrinter];
}



-(void)generatePrinterMenu:(NSMenu*)menu {
    //get list of printers and make menu-items for them
    NSArray *printers = [[PrintManager sharedInstance] printersAvailable];
    [printers enumerateObjectsUsingBlock:^(NSString *printerName, NSUInteger idx, BOOL *stop) {
        NSMenuItem *printer = [menu addItemWithTitle:printerName
                        action:@selector(changeCurrentPrinterTo:)
                 keyEquivalent:@""];
        [printer setTarget:self];
    }];
}


-(void)changeCurrentPrinterTo:(NSMenuItem*)sender {
    //change Active Printer
    self.printerName = sender.title;
    
    //save choice for next launch
    [[FileManager sharedInstance] savePreferences];
    
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
    
    if (self.printerName) {
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title isEqualToString:self.printerName]) {
                chosenMenuItem = item;
            }
        }];
    }
    //if we couldn't find a printer matched saved preferences, look for a zebra
    if (!chosenMenuItem) {
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:@"zebra" options:NSCaseInsensitiveSearch].length>0) {
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
