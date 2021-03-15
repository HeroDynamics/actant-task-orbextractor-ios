#ifndef LIBORBORIGINAL_H
#define LIBORBORIGINAL_H

#include <opencv2/opencv.hpp>
#include "ORBextractorOriginal.h"

// NOTE [smuravev] ВНИМАНИЕ: Никогда НЕ меняйте порядок полей
//                 в данной структуре. Так как именно этот порядок
//                 используется при десериализации C++ данных в Swift (GRPC).
struct pb_KeyPoint {
    float pos[2];
    float radius;
    float orientation;
    float response;
};

// NOTE [smuravev] ВНИМАНИЕ: Никогда НЕ меняйте порядок полей
//                 в данной структуре. Так как именно этот порядок
//                 используется при десериализации C++ данных в Swift (GRPC).
struct pb_OrbFeaturePoint {
    pb_KeyPoint key_point;
    unsigned char descriptor[32];
};

class LibORBOriginal {
public:
    LibORBOriginal(int max_feature_points);
    ~LibORBOriginal();
    void DetectAndCompute(void *y_plane_bytes,
                          int y_plane_width,
                          int y_plane_height,
                          int y_plane_bytes_per_row,
                          float decrease_image_resolution_in_n_times,
                          bool exclude_empty_key_points,
                          std::vector<pb_OrbFeaturePoint> &orb_feature_points,
                          const char *compatibility_file_path);

private:
    cv::Mat orb_descriptors;
    std::vector<cv::KeyPoint> key_points;
    ORB_SLAM3_ORIGINAL::ORBextractorOriginal *orb_extractor;
};

#endif
