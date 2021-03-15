//
//  LibORBWrapperOriginal.mm
//  Actant
//
//  Created by Sergey Muravev on 30.01.2021.
//  Copyright © 2021 Actant. All rights reserved.
//

#import "LibORBWrapperOriginal.h"

// NOTE [smuravev] Мы используем след макрос для удаления "определений" YES, NO (кот.
//                 добавляет Foundation framework iOS).
//                 Для того чтобы они НЕ конфликтовали со значениями enum-ов в opencv библиотеке.
//                 См. детальнее о данной проблеме здесь: https://github.com/opencv/opencv/issues/6114
#ifdef __cplusplus
#undef NO
#undef YES
#import "liborb_original.h"
#endif

@interface LibORBWrapperOriginal ()
@property (nonatomic, assign) LibORBOriginal* libOrb;
@end

@implementation LibORBWrapperOriginal

- (instancetype)init {
    self = [self initWithMaxFeaturePoints:1000];
    return self;
}

- (instancetype)initWithMaxFeaturePoints:(int) maxFeaturePoints {
    self = [super init];
    if (self) {
        _libOrb = new LibORBOriginal(maxFeaturePoints);
    }
    return self;
}

- (NSArray *)detectAndCompute
    :(NSData *) yPlaneBufferData
    :(int) yPlaneWidth
    :(int) yPlaneHeight
    :(int) yPlaneBytesPerRow
    :(float) decreaseImageResolutionInNTimes
    :(bool) excludeEmptyKeyPoints
    :(NSString *) compatibilityFilePath
{
    
    // yPlane (Luma values)
    uint8_t *yPlaneBytes = (uint8_t *)yPlaneBufferData.bytes;
    
    std::vector<pb_OrbFeaturePoint> pbFeaturePoints;
    
    _libOrb->DetectAndCompute(yPlaneBytes,
                              yPlaneWidth,
                              yPlaneHeight,
                              yPlaneBytesPerRow,
                              decreaseImageResolutionInNTimes,
                              excludeEmptyKeyPoints,
                              pbFeaturePoints,
                              (const char*)[compatibilityFilePath UTF8String]);
    
    unsigned long pbFeaturePointsSize = pbFeaturePoints.size();
    NSMutableArray *serializedFeaturePoints = [[NSMutableArray alloc] initWithCapacity:pbFeaturePointsSize];
    
    int i;
    for(i = 0; i < pbFeaturePointsSize; i++) {
        pb_OrbFeaturePoint pbFeaturePoint = pbFeaturePoints.at(i);
        
        NSData *serializedFeaturePoint = [NSData dataWithBytes:&pbFeaturePoint length:sizeof(pbFeaturePoint)];
        [serializedFeaturePoints addObject:serializedFeaturePoint];
    }

    pbFeaturePoints.clear();
    
    return serializedFeaturePoints;
}

- (void)dealloc {
    if (_libOrb) {
        delete _libOrb;
    }
    _libOrb = nil;
}

@end
