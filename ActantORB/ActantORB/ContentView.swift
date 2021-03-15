//
//  ContentView.swift
//  ActantORB
//
//  Created by Sergey Muravev on 15.03.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State var inProgress = -1
    
    var body: some View {
        if inProgress < 0 {
            Button(action: {
                DispatchQueue.global(qos: .default).async {
                    DispatchQueue.main.async { self.inProgress = 0 }
                    
                    let ITERATIONS_COUNT = 100
                    let imageResolutionDecreaseFactors: [Float] = [
                        1.0,
                        1.5,
                        2.0,
                        3.0
                    ]
                    
                    let yPlaneWidth = 1920
                    let yPlaneHeight = 1440
                    let yPlaneBytesPerRow = yPlaneWidth
                    
                    print("""
                    \n
                    #
                    # ORBExtractor - performance
                    #
                    """)
                    for r in 0..<imageResolutionDecreaseFactors.count {
                        let imageResolutionDecreaseFactor = imageResolutionDecreaseFactors[r]
                        
                        let resolutionWidth = Int(Float(yPlaneWidth) / imageResolutionDecreaseFactor)
                        let resolutionHeight = Int(Float(yPlaneHeight) / imageResolutionDecreaseFactor)
                        
                        let resolution = "\(resolutionWidth)x\(resolutionHeight)"
                        print("\nResolution: \(resolution)")
                        
                        var originalElapsedMin = TimeInterval.greatestFiniteMagnitude
                        var optimizedElapsedMin = TimeInterval.greatestFiniteMagnitude
                        
                        let libOrbWrapperOriginal = LibORBWrapperOriginal(maxFeaturePoints: 1000)
                        let libOrbWrapperOptimized = LibORBWrapper(maxFeaturePoints: 1000)
                        
                        for i in 0..<ITERATIONS_COUNT {
                            //
                            // ORIGINAL
                            //
                            guard let yPlaneBufferDataOriginal = NSDataAsset(name: "luma-frame-data")?.data else {
                                print("TEST [ORBExtractor ORIGINAL]: ERROR: unable to get yPlaneBufferData from `luma-frame-data` asset")
                                return
                            }
                            
                            let originalStartTimestamp = Date().timeIntervalSince1970
                            guard let originalDatas = libOrbWrapperOriginal.detectAndCompute(
                                yPlaneBufferDataOriginal,
                                Int32(yPlaneWidth),
                                Int32(yPlaneHeight),
                                Int32(yPlaneBytesPerRow),
                                imageResolutionDecreaseFactor,
                                false,
                                ""
                            ) as? [Data] else {
                                print("TEST [ORBExtractor ORIGINAL]: ERROR: unable to detectAndCompute")
                                return
                            }
                            let originalEndTimestamp = Date().timeIntervalSince1970
                            let originalElapsed = originalEndTimestamp - originalStartTimestamp
                            if originalElapsed < originalElapsedMin {
                                originalElapsedMin = originalElapsed
                            }
                            
                            //
                            // OPTIMIZED
                            //
                            guard let yPlaneBufferDataOptimized = NSDataAsset(name: "luma-frame-data")?.data else {
                                print("TEST [ORBExtractor OPTIMIZED]: ERROR: unable to get yPlaneBufferData from `luma-frame-data` asset")
                                return
                            }
                            
                            let optimizedStartTimestamp = Date().timeIntervalSince1970
                            guard let optimizedDatas = libOrbWrapperOptimized.detectAndCompute(
                                yPlaneBufferDataOptimized,
                                Int32(yPlaneWidth),
                                Int32(yPlaneHeight),
                                Int32(yPlaneBytesPerRow),
                                imageResolutionDecreaseFactor,
                                false,
                                ""
                            ) as? [Data] else {
                                print("TEST [ORBExtractor OPTIMIZED]: ERROR: unable to detectAndCompute")
                                return
                            }
                            let optimizedEndTimestamp = Date().timeIntervalSince1970
                            let optimizedElapsed = optimizedEndTimestamp - optimizedStartTimestamp
                            if optimizedElapsed < optimizedElapsedMin {
                                optimizedElapsedMin = optimizedElapsed
                            }
                            
                            let total = imageResolutionDecreaseFactors.count * ITERATIONS_COUNT
                            let inProgress: Int = (r * ITERATIONS_COUNT + i) * 100 / total
                            DispatchQueue.main.async { self.inProgress = inProgress }
                        }
                        
                        let originalElapsed_1fps = originalElapsedMin
                        let optimizedElapsed_1fps = optimizedElapsedMin
                        
                        print("    ITERATIONS:       \(ITERATIONS_COUNT)")
                        print("    ELAPSED (1 fps):  \(originalElapsed_1fps) | \(optimizedElapsed_1fps)")
                        print("    ELAPSED (15 fps): \(originalElapsed_1fps * 15.0) | \(optimizedElapsed_1fps * 15.0)")
                        print("    ELAPSED (30 fps): \(originalElapsed_1fps * 30.0) | \(optimizedElapsed_1fps * 30.0)")
                        
                        let improvement = originalElapsed_1fps / optimizedElapsed_1fps
                        print("    ELAPSED (improvement): (\(improvement < 1.0 ? "-" : "+")) \(improvement < 1.0 ? 1.0 / improvement : improvement)")
                    }
                    DispatchQueue.main.async { self.inProgress = 100 }
                    
                    
                    print("""
                    \n
                    #
                    # ORBExtractor - compatibility
                    #
                    """)
                    let fileManager = FileManager.default
                    var dd: URL?
                    do {
                        dd = try fileManager.url(
                            for: .documentDirectory,
                            in: .userDomainMask,
                            appropriateFor: nil,
                            create: true
                        )
                    } catch {
                        print("TEST [ORBExtractor]: ERROR: \(error)")
                    }
                    guard let documentDirectory = dd else { return }
                    
                    imageResolutionDecreaseFactors.forEach { imageResolutionDecreaseFactor in
                        let resolutionWidth = Int(Float(yPlaneWidth) / imageResolutionDecreaseFactor)
                        let resolutionHeight = Int(Float(yPlaneHeight) / imageResolutionDecreaseFactor)
                        
                        let resolution = "\(resolutionWidth)x\(resolutionHeight)"
                        print("\nResolution: \(resolution)")
                        
                        //
                        // ORIGINAL
                        //
                        guard let yPlaneBufferDataOriginal = NSDataAsset(name: "luma-frame-data")?.data else {
                            return
                        }
                        
                        let libOrbWrapperOriginal = LibORBWrapperOriginal(maxFeaturePoints: 1000)
                        
                        let originalFileUrl = documentDirectory.appendingPathComponent("compatibility-original-\(resolution).jpg")
                        
                        let originalDatas = libOrbWrapperOriginal.detectAndCompute(
                            yPlaneBufferDataOriginal,
                            Int32(yPlaneWidth),
                            Int32(yPlaneHeight),
                            Int32(yPlaneBytesPerRow),
                            imageResolutionDecreaseFactor,
                            false,
                            originalFileUrl.path
                        )
                        
                        let originalCompatibilityCount = originalDatas.count
                        
                        //
                        // OPTIMIZED
                        //
                        guard let yPlaneBufferDataOptimized = NSDataAsset(name: "luma-frame-data")?.data else {
                            return
                        }
                        
                        let libOrbWrapperOptimized = LibORBWrapper(maxFeaturePoints: 1000)
                        
                        let optimizedFileUrl = documentDirectory.appendingPathComponent("compatibility-optimized-\(resolution).jpg")
                        
                        let optimizedDatas = libOrbWrapperOptimized.detectAndCompute(
                            yPlaneBufferDataOptimized,
                            Int32(yPlaneWidth),
                            Int32(yPlaneHeight),
                            Int32(yPlaneBytesPerRow),
                            imageResolutionDecreaseFactor,
                            false,
                            optimizedFileUrl.path
                        )
                        
                        let optimizedCompatibilityCount = optimizedDatas.count
                        
                        print("    COMPATIBILITY (count): \(originalCompatibilityCount) | \(optimizedCompatibilityCount) [\(originalCompatibilityCount == optimizedCompatibilityCount)]")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.inProgress = -1 }
                }
            }) {
                Text("RUN TEST")
            }
            .padding()
        } else {
            Text("IN PROGRESS: \(self.inProgress)%")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
