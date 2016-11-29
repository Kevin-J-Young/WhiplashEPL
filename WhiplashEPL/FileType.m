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


#pragma mark - NSCoding

+(FileType*)withTypelist:(NSArray*)extensions andPrinterName:(NSString*)printer {
    return [[FileType alloc] initWithTypelist:extensions andPrinterName:printer];
}

-(instancetype)initWithTypelist:(NSArray*)extensions andPrinterName:(NSString*)printer {
    if (self = [super init]) {
        //double extension list with upcase & downcase
        NSMutableSet *tempExtensions = [NSMutableSet set];
        [extensions enumerateObjectsUsingBlock:^(NSString *extension, NSUInteger idx, BOOL *stop) {
            [tempExtensions addObject:[extension lowercaseString]];
            [tempExtensions addObject:[extension uppercaseString]];
        }];
        self.fileExtensionList = [[tempExtensions allObjects] sortedArrayUsingSelector:@selector(localizedCompare:)];

        self.printerName = printer;
        [self setAction:nil];
        [self setKeyEquivalent:@""];
        [self setSubmenu:[[NSMenu alloc] initWithTitle:self.title]];
        
        [self buildMenuItem];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self initWithTypelist:[decoder decodeObjectForKey:@"fileExtensionList"]
                   andPrinterName:[decoder decodeObjectForKey:@"printerName"]];
    if (!self) {
        return nil;
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileExtensionList forKey:@"fileExtensionList"];
    NSLog(@"about to crash? printer_name: %@", self.printerName);
    if (self.printerName.length > 1) {
        [encoder encodeObject:self.printerName forKey:@"printerName"];
    } else {
        NSLog(@"skip encoding to avoid empty-printer crash");
    }
}

-(NSString*)title {
    return _fileExtensionList.firstObject;
}

-(void)buildMenuItem {
    [self generatePrinterMenu:self.submenu];
    NSLog(@"%@ menu created", [self.fileExtensionList firstObject]);
    [self chooseDefaultPrinter];
    NSLog(@"%@ menu finished", [self.fileExtensionList firstObject]);
}



-(void)generatePrinterMenu:(NSMenu*)menu {
    NSString *fileExString = [self.fileExtensionList componentsJoinedByString:@", "];
    [menu addItemWithTitle:fileExString action:nil keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
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
    [self moveCheckmarkTo:sender.title];
    
}

-(void)moveCheckmarkTo:(NSString*)newPrinterChoice {
    NSLog(@"adding checkmark");
    [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        if ([item.title isEqualToString:newPrinterChoice]) {
            [item setState:NSOnState];
        } else {
            [item setState:NSOffState];
        }
    }];
}

-(void)chooseDefaultPrinter {
    __block NSMenuItem *chosenMenuItem;
    
    if (self.printerName) {
        NSLog(@"searching %lu printers for '%@'", self.submenu.itemArray.count, self.printerName);
        [self.submenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            if ([item.title rangeOfString:self.printerName options:NSCaseInsensitiveSearch].length>0) {
                chosenMenuItem = item;
            }
        }];
    } else {
        NSLog(@"ERROR: failed to get printer name");
    }
    if (chosenMenuItem) {
        NSLog(@"selected: %@", chosenMenuItem.title);
        [self moveCheckmarkTo:chosenMenuItem.title];
        [self setPrinterName:chosenMenuItem.title];
    }
}

@end
