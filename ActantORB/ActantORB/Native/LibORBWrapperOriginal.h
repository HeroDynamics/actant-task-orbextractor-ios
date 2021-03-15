//
//  LibORBWrapperOriginal.h
//  Actant
//
//  Created by Sergey Muravev on 30.01.2021.
//  Copyright © 2021 Actant. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibORBWrapperOriginal: NSObject
- (instancetype)init;
- (instancetype)initWithMaxFeaturePoints:(int) maxFeaturePoints;
- (void)dealloc;
- (NSArray *)detectAndCompute
    :(NSData *) yPlaneBufferData
    :(int) yPlaneWidth
    :(int) yPlaneHeight
    :(int) yPlaneBytesPerRow
    :(float) decreaseImageResolutionInNTimes
    :(bool) excludeEmptyKeyPoints
    :(NSString *) compatibilityFilePath;
@end

NS_ASSUME_NONNULL_END
