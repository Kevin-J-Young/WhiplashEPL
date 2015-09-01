//
//  PrinterMenu.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/31/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrinterMenu : NSMenuItem

@property (nonatomic, strong, readonly) NSString *selectedPrinter;
@property (nonatomic, strong, readonly) NSArray *fileTypes;

+(PrinterMenu*)menuForFileTypes:(NSArray*)fileTypes preferedPrinter:(NSString*)preferedPrinter;

@end
