//
//  LibORBWrapper.mm
//  Actant
//
//  Created by Sergey Muravev on 20.12.2020.
//  Copyright © 2020 Actant. All rights reserved.
//

#import "LibORBWrapper.h"

// NOTE [smuravev] Мы используем след макрос для удаления "определений" YES, NO (кот.
//                 добавляет Foundation framework iOS).
//                 Для того чтобы они НЕ конфликтовали со значениями enum-ов в opencv библиотеке.
//                 См. детальнее о данной проблеме здесь: https://github.com/opencv/opencv/issues/6114
#ifdef __cplusplus
#undef NO
#undef YES
#import "liborb.h"
#endif

@interface LibORBWrapper ()
@property (nonatomic, assign) LibORB* libOrb;
@end

@implementation LibORBWrapper

- (instancetype)init {
    self = [self initWithMaxFeaturePoints:1000];
    return self;
}

- (instancetype)initWithMaxFeaturePoints:(int) maxFeaturePoints {
    self = [super init];
    if (self) {
        _libOrb = new LibORB(maxFeaturePoints);
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
