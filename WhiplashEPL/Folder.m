//
//  Folder.m
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "Folder.h"

#import "FileType.h"
#import "FileManager.h"
#import "AppDelegate.h"

@implementation Folder

@synthesize fileTypes = _fileTypes;
@synthesize url = _url;


-(instancetype)initWithFiletypes:(NSArray*)filetypes andFolderPath:(NSString*)url {
    if (self = [super init]) {
        self.fileTypes = filetypes;
        if (!self.fileTypes) {
            self.fileTypes = [NSArray array];
        }
        self.url = url;
        
        [self setTarget:self];
        [self setAction:@selector(editPath:)];
        [self setKeyEquivalent:@""];
        [self setTitle:@"Watched Folder..."];
    }
    return self;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [self initWithFiletypes:[decoder decodeObjectForKey:@"fileTypes"]
                     andFolderPath:[decoder decodeObjectForKey:@"url"]];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileTypes forKey:@"fileTypes"];
    [encoder encodeObject:self.url forKey:@"url"];
}

-(void)addToMenu:(NSMenu*)menu {
    NSString *version_string = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [menu addItemWithTitle:version_string action:nil keyEquivalent:@""];
    
    [menu insertItem:self atIndex:menu.numberOfItems];
    [[menu insertItemWithTitle:@"New File Type..." action:@selector(addFileType) keyEquivalent:@"" atIndex:menu.numberOfItems] setTarget:self];
    
    [self.fileTypes enumerateObjectsUsingBlock:^(FileType *filetype, NSUInteger idx, BOOL *stop) {
        [menu insertItem:filetype atIndex:menu.numberOfItems];
    }];
}

-(NSInteger)highestFiletypeIndex {
    __block NSInteger highest = 0;
    [self.fileTypes enumerateObjectsUsingBlock:^(FileType *ft, NSUInteger idx, BOOL *stop) {
        if ([self.menu indexOfItem:ft] > highest) {
            highest = [self.menu indexOfItem:ft];
        }
    }];
    return highest;
}

-(void)addFileType {
    //get user input
    NSString *st = [self input:@"enter file extentions to watch for, separated by spaces" defaultValue:@"epl epl2 EPL"];
    
    //create FileType object
    FileType *ft = [FileType withTypelist:[st componentsSeparatedByString:@" "] andPrinterName:@"choose Printer"];
    
    //add to running model
    self.fileTypes = [self.fileTypes arrayByAddingObject:ft];
    [[FileManager sharedInstance] savePreferences];

    
    //add to menu view
    [self.menu insertItem:ft atIndex:[self highestFiletypeIndex]];
}


- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}



-(void)editPath:(Folder*)sender {
    self.url = [[[self chooseFolder] path] stringByAbbreviatingWithTildeInPath];
    [sender setTitle:self.url];
}

-(NSURL*)chooseFolder {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Disable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setPrompt:@"Select"];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    NSURL* dir = nil;
    if ( [openDlg runModal] == NSModalResponseOK )
    {
        // Get directory selected
        dir = [openDlg URLs].firstObject;
    }
    return dir;
}

-(NSString*)fullPath {
    return [self.url stringByExpandingTildeInPath];
}


@end
