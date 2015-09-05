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
//@synthesize logPath = _logPath;

+(FileManager*)sharedInstance {
    static FileManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FileManager alloc] init];
    });
    return _sharedInstance;
}

-(NSString*)logPath {
//    if (!_logPath) {
        NSString *dl = [[self downloadsFolder] stringByExpandingTildeInPath];
        NSString *path = [dl stringByAppendingString:@"/LOG.txt"];
//        _logPath = path;
//        NSLog(@"%@", path);
//        _logPath = @"/Users/kevinyoung/Downloads/WHIP-Log.txt";
//    }
//    return @"/Users/kevinyoung/Downloads/WHIP-Log.txt";
//    NSLog(@"%@", _logPath);
    return path;
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
//    NSLog(@"%@", downloadsDirectory);
    return downloadsDirectory;
}

//-(NSString*)logPath {
//    return [[self downloadsFolder] stringByAppendingPathComponent:@"logFile.txt"];
//}




#pragma mark - logFile
-(void)createLogfile {
//    Folder *fol = (Folder*)self.watchedFolders.firstObject;
//    _logPath = [fol.fullPath stringByAppendingPathComponent:@"foo.txt"];
//    NSLog(@"%@", _logPath);
    
//    [[NSFileManager defaultManager] createFileAtPath:self.logPath contents:nil attributes:nil];
    [self appendLine:@"firstLine" ToFile:self.logPath encoding:NSUTF8StringEncoding];
}

-(void)writeToLog:(NSString*)line {
//    if ([[NSFileManager defaultManager] isReadableFileAtPath:self.logPath]) {
//        NSString *contents = [NSString stringWithFormat:@"%@\n%@", [NSString stringWithContentsOfFile:self.logPath], line];
//        
//        [contents writeToFile:self.logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    } else {
//        NSLog(@"no file");
//    }
    [self appendLine:line ToFile:self.logPath encoding:NSUTF8StringEncoding];
}




- (BOOL)appendLine:(NSString*)line ToFile:(NSString *)path encoding:(NSStringEncoding)enc;
{
    line = [NSString stringWithFormat:@"%@\n", line];
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return NO;
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[line dataUsingEncoding:enc]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}

@end
