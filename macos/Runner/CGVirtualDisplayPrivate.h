//
//  CGVirtualDisplayPrivate.h
//  Runner
//
//  Created for Native Display virtual monitor management.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGVirtualDisplayMode : NSObject

@property(readonly, nonatomic) double refreshRate;
@property(readonly, nonatomic) unsigned int height;
@property(readonly, nonatomic) unsigned int width;

- (instancetype)initWithWidth:(unsigned int)width 
                       height:(unsigned int)height 
                  refreshRate:(double)refreshRate;

@end

@interface CGVirtualDisplaySettings : NSObject

@property(retain, nonatomic) NSArray<CGVirtualDisplayMode *> *modes;
@property(nonatomic) unsigned int hiDPI;
@property(nonatomic) double rotation;

- (instancetype)init;

@end

@class CGVirtualDisplay;

@interface CGVirtualDisplayDescriptor : NSObject

@property(retain, nonatomic) dispatch_queue_t queue;
@property(retain, nonatomic) NSString *name;
@property(nonatomic) unsigned int maxPixelsHigh;
@property(nonatomic) unsigned int maxPixelsWide;
@property(nonatomic) CGSize sizeInMillimeters;
@property(nonatomic) unsigned int serialNum;
@property(nonatomic) unsigned int productID;
@property(nonatomic) unsigned int vendorID;
@property(nonatomic) double rotation;
@property(copy, nonatomic, nullable) void (^terminationHandler)(id, CGVirtualDisplay *);

- (instancetype)init;

@end

@interface CGVirtualDisplay : NSObject

@property(readonly, nonatomic) NSArray *modes;
@property(readonly, nonatomic) unsigned int hiDPI;
@property(readonly, nonatomic) CGDirectDisplayID displayID;
@property(readonly, nonatomic, nullable) id terminationHandler;
@property(readonly, nonatomic) dispatch_queue_t queue;
@property(readonly, nonatomic) unsigned int maxPixelsHigh;
@property(readonly, nonatomic) unsigned int maxPixelsWide;
@property(readonly, nonatomic) CGSize sizeInMillimeters;
@property(readonly, nonatomic) NSString *name;
@property(readonly, nonatomic) unsigned int serialNum;
@property(readonly, nonatomic) unsigned int productID;
@property(readonly, nonatomic) unsigned int vendorID;
@property(readonly, nonatomic) double rotation;

- (nullable instancetype)initWithDescriptor:(CGVirtualDisplayDescriptor *)descriptor;
- (BOOL)applySettings:(CGVirtualDisplaySettings *)settings;

@end

NS_ASSUME_NONNULL_END
