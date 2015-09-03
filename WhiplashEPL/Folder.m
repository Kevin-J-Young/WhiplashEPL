//
//  Folder.m
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "Folder.h"

#import "FileType.h"

@implementation Folder

@synthesize fileTypes = _fileTypes;
@synthesize url = _url;

-(NSString*)title {
    return _url;
}


-(NSString*)description {
    return [NSString stringWithFormat:@"%@ - %@", self.url, self.fileTypes];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.fileTypes = [decoder decodeObjectForKey:@"fileTypes"];
    self.url = [decoder decodeObjectForKey:@"url"];
    
    [self setTarget:self];
    [self setAction:@selector(editPath:)];
    [self setKeyEquivalent:@""];
    
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fileTypes forKey:@"fileTypes"];
    [encoder encodeObject:self.url forKey:@"url"];
}

-(void)addToMenu:(NSMenu*)menu {
    [menu insertItem:self atIndex:menu.numberOfItems];
    
    [self.fileTypes enumerateObjectsUsingBlock:^(FileType *filetype, NSUInteger idx, BOOL *stop) {
        [menu insertItem:filetype atIndex:menu.numberOfItems];
    }];
}



-(void)setupDefaults {
    self.url = [self downloadsFolder];
    
    FileType *epl = [[FileType alloc] init];
    epl.fileExtensionList = @[@"epl", @"epl2", @"EPL", @"EPL2"];
    epl.printerName = @"Debug";
    
    FileType *pdf = [[FileType alloc] init];
    pdf.fileExtensionList = @[@"pdf", @"PDF"];
    pdf.printerName = @"Debug";
    
    self.fileTypes = @[epl, pdf];
}



-(NSString*)downloadsFolder {
    NSString *downloadsDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, NO);
    if ([paths count] > 0) {
        downloadsDirectory = [paths objectAtIndex:0];
    }
    NSLog(@"%@", downloadsDirectory);
    return downloadsDirectory;
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
    NSURL* dir;
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
