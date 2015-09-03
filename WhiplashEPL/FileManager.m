//
//  FileManager.m
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import "FileManager.h"

#import "Folder.h"
#import "FileType.h"



@implementation FileManager
@synthesize watchedFolders = _watchedFolders;

+(FileManager*)sharedInstance {
    static FileManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FileManager alloc] init];
    });
    return _sharedInstance;
}



#pragma mark - NSCoding
-(void)savePreferences {
    if (self.watchedFolders) {
        NSLog(@"SAVING: %@", self.watchedFolders);
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.watchedFolders];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"watchedFolders"];
    } else {
        NSLog(@"couldn't find anything to save");
    }
}

-(void)loadPreferences {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"watchedFolders"];
    if (data) {
        self.watchedFolders = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"LOADED: %@", self.watchedFolders);
    } else {
        NSLog(@"failed to load preferences, creating defaults..");
        [self buildDefaultPreferences];
        [self savePreferences];
    }
}

- (void)deletePreferences {
    NSLog(@"deleting preferences to start fresh");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunchComplete"];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

-(void)buildDefaultPreferences {
    NSLog(@"building default preferences");
    FileType *epl = [FileType withTypelist:@[@"EPL2", @"epl"] andPrinterName:@"zebra"];
    FileType *pdf = [FileType withTypelist:@[@"pdf"] andPrinterName:@"choose Printer"];
    FileType *png = [FileType withTypelist:@[@"png", @"PNG"] andPrinterName:@"choose Printer"];

    Folder *folder = [[Folder alloc] initWithFiletypes:@[epl, pdf, png] andFolderPath:[self downloadsFolder]];
    self.watchedFolders = @[folder];
    [self savePreferences];
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
@end
