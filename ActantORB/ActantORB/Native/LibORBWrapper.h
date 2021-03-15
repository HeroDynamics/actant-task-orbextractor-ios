//
//  LibORBWrapper.h
//  Actant
//
//  Created by Sergey Muravev on 20.12.2020.
//  Copyright © 2020 Actant. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LibORBWrapper: NSObject
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
