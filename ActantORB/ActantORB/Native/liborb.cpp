#include "liborb.h"

using namespace cv;
using namespace std;

LibORB::LibORB(int max_feature_points)
{
    orb_extractor = new ORB_SLAM3::ORBextractor(max_feature_points, 1.5f, 4, 20, 7);
}

LibORB::~LibORB(void)
{
    if (orb_extractor) {
        delete orb_extractor;
    }
    orb_extractor = NULL;

    orb_descriptors.release();
    key_points.clear();
}

void LibORB::DetectAndCompute(void *y_plane_bytes,
                              int y_plane_width,
                              int y_plane_height,
                              int y_plane_bytes_per_row,
                              float decrease_image_resolution_in_n_times,
                              bool exclude_empty_key_points,
                              std::vector<pb_OrbFeaturePoint> &orb_feature_points,
                              const char *compatibility_file_path)
{
    if (!orb_extractor) {
        return;
    }

    // yPlane (Luma values)
    Mat y_plane = Mat(y_plane_height, y_plane_width, CV_8U, y_plane_bytes, y_plane_bytes_per_row);

    if (decrease_image_resolution_in_n_times > 1) {
        float w = y_plane_width / decrease_image_resolution_in_n_times;
        float h = y_plane_height / decrease_image_resolution_in_n_times;
        cv::resize(y_plane, y_plane, Size(w, h));
    }

    // NOTE [smuravev] Мы передаем формируем массив vLappingArea со значениеями [1, 0] внутри.
    //                 Это гарантирует что в работе `ORBextractor::operator()` НЕ будет использоваться
    //                 'stereo fisheye' условие при расчете features points (descriptors) - а будет
    //                 использоваться ТОЛЬКО `monoIndex` (одна камера) - см. тело (реализацию) `ORBextractor::operator()`
    std::vector<int> vLappingArea;
    vLappingArea.push_back(1);
    vLappingArea.push_back(0);
    orb_extractor->operator()(y_plane, cv::noArray(), key_points, orb_descriptors, vLappingArea);
    
    // NOTE [smuravev] Закомментированный код - это пример вычисления features points (и дескрипторов)
    //                 посредством OpenCV функции detectAndCompute.
    //                 По словам Аркадия такие дескрипторы хуже ORB-SLAM3 дескрипторов, которые мы вычисляем
    //                 посредством `orb_extractor->operator()` (см код выше).
    //                 ВНИМАНИЕ: я оставил этот пример кода, так как провел тест производительности (скорость
    //                 вычисления дескрипторов по 1-му кадру). Сравнив результаты, OpenCV-ые дескрипторы вычисляются
    //                 примерно в 2 раза быстрее (~0.019 сек на кадр) чем это делает ORBExtractor (~0.036 сек на кадр).
    //                 Тестирование производительности вычисления производилось на iPhone 8 Plus.
//    cv::Ptr<cv::FeatureDetector> fd = cv::ORB::create(1000);
//    fd->detectAndCompute(y_plane, cv::noArray(), key_points, orb_descriptors);
    
    for (size_t i = 0; i < key_points.size(); i++)
    {
        // NOTE [smuravev] Здесь мы проверяем не является ли keyPoint ORB дескриптора
        //                 "пустышкой" (radius > 0). Игнорируем (НЕ добавляем такую точку в ответ).
        //                 OpenCV всегда возвращает ~1000 keyPoint-ов (треть из которых может
        //                 быть "пустышками"). Аркадий и Роман, подтвердили что такие "пустышки"
        //                 им не нужны и их надо исключать из телеметрии - что мы тут и делаем.
        float radius = key_points.at(i).size;
        if (exclude_empty_key_points && radius <= 0) {
            continue;
        }
        
        orb_feature_points.emplace_back(pb_OrbFeaturePoint());
        memcpy(orb_feature_points.back().descriptor, orb_descriptors.row(i).data, 32);
        orb_feature_points.back().key_point.pos[0] = key_points.at(i).pt.x;
        orb_feature_points.back().key_point.pos[1] = key_points.at(i).pt.y;
        orb_feature_points.back().key_point.radius = radius;
        orb_feature_points.back().key_point.orientation = key_points.at(i).angle;
        orb_feature_points.back().key_point.response = key_points.at(i).response;
    }

    if (*compatibility_file_path) { // string not blank
        // Type CV_8UC1- grayscale image
        // 8 bits per pixel and so range of [0:255].
        // Scalar color = new Scalar( 255 )
        // For type: 16UC1, range of [0:65535]. For 32FC1 range is [0.0f:1.0f]
        //
        // Type CV_8UC3 - 3 channel color image
        // BLUE: color ordering as BGR
        // Scalar color = new Scalar( 255, 0, 0 )
        //
        // Type CV_8UC4 - color image with transparency
        // Transparent GREEN: BGRA with alpha range - [0 : 255]
        // Scalar color = new Scalar( 0, 255, 0, 128 )

        cv::drawKeypoints(y_plane, key_points, y_plane, cv::Scalar(0, 255, 0, 128), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
        bool result = cv::imwrite(compatibility_file_path, y_plane);
        if (result) {
            std::cout << compatibility_file_path << " - DONE" << endl;
        } else {
            std::cout << compatibility_file_path << " - FAILED" << endl;
        }
    }
}
