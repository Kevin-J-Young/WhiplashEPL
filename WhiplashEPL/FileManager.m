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

- (void)refreshUserDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

-(void)buildDefaultPreferences {
    NSLog(@"building default preferences");
    Folder *folder = [[Folder alloc] init];
    [folder setupDefaults];
    self.watchedFolders = @[folder];
}

@end
