#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>
#include <windows.h>

class ImageRecognizer {
private:
    double confidenceThreshold;

public:
    ImageRecognizer(double threshold = 0.8) : confidenceThreshold(threshold) {}

    // 截取屏幕
    cv::Mat captureScreen() {
        HDC hdc = GetDC(NULL); // 获取屏幕DC
        HDC hdcMem = CreateCompatibleDC(hdc);

        int screenWidth = GetSystemMetrics(SM_CXSCREEN);
        int screenHeight = GetSystemMetrics(SM_CYSCREEN);

        HBITMAP hBitmap = CreateCompatibleBitmap(hdc, screenWidth, screenHeight);
        SelectObject(hdcMem, hBitmap);
        BitBlt(hdcMem, 0, 0, screenWidth, screenHeight, hdc, 0, 0, SRCCOPY);

        // 将BITMAP转换为OpenCV Mat
        BITMAPINFOHEADER bi;
        bi.biSize = sizeof(BITMAPINFOHEADER);
        bi.biWidth = screenWidth;
        bi.biHeight = -screenHeight; // 负高度表示从上到下的位图
        bi.biPlanes = 1;
        bi.biBitCount = 32;
        bi.biCompression = BI_RGB;
        bi.biSizeImage = 0;
        bi.biXPelsPerMeter = 0;
        bi.biYPelsPerMeter = 0;
        bi.biClrUsed = 0;
        bi.biClrImportant = 0;

        cv::Mat screen(screenHeight, screenWidth, CV_8UC4);
        GetDIBits(hdc, hBitmap, 0, screenHeight, screen.data, (BITMAPINFO*)&bi, DIB_RGB_COLORS);

        // 转换为BGR格式
        cv::Mat screenBGR;
        cv::cvtColor(screen, screenBGR, cv::COLOR_BGRA2BGR);

        // 清理资源
        DeleteObject(hBitmap);
        DeleteDC(hdcMem);
        ReleaseDC(NULL, hdc);

        return screenBGR;
    }

    // 查找图像中心位置
    cv::Point findImageCenter(const std::string& templatePath) {
        // 读取模板图像
        cv::Mat templateImg = cv::imread(templatePath);
        if (templateImg.empty()) {
            std::cerr << "无法加载模板图像: " << templatePath << std::endl;
            return cv::Point(-1, -1);
        }

        // 截取屏幕
        cv::Mat screen = captureScreen();

        // 模板匹配
        cv::Mat result;
        cv::matchTemplate(screen, templateImg, result, cv::TM_CCOEFF_NORMED);

        // 找到最佳匹配位置
        double minVal, maxVal;
        cv::Point minLoc, maxLoc;
        cv::minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

        std::cout << "匹配置信度: " << maxVal << std::endl;

        // 检查置信度是否达到阈值
        if (maxVal < confidenceThreshold) {
            std::cout << "未找到匹配图像，置信度太低: " << maxVal << std::endl;
            return cv::Point(-1, -1);
        }

        // 计算中心点
        cv::Point center;
        center.x = maxLoc.x + templateImg.cols / 2;
        center.y = maxLoc.y + templateImg.rows / 2;

        std::cout << "找到图像，中心位置: (" << center.x << ", " << center.y << ")" << std::endl;

        return center;
    }

    // 设置置信度阈值
    void setConfidenceThreshold(double threshold) {
        confidenceThreshold = threshold;
    }

    // 模拟按键（Ctrl+Space）
    void pressCtrlSpace() {
        // 按下Ctrl
        keybd_event(VK_CONTROL, 0, 0, 0);
        // 按下Space
        keybd_event(VK_SPACE, 0, 0, 0);
        // 释放Space
        keybd_event(VK_SPACE, 0, KEYEVENTF_KEYUP, 0);
        // 释放Ctrl
        keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

        std::cout << "已按下 Ctrl+Space" << std::endl;
    }
};

int main() {
    ImageRecognizer recognizer(0.5); // 设置置信度阈值为0.5

    // 等待2秒
    Sleep(2000);

    // 查找图像（替换为你的图像路径）
    std::string imagePath = "sogo.png";
    cv::Point center = recognizer.findImageCenter(imagePath);

    if (center.x != -1 && center.y != -1) {
        recognizer.pressCtrlSpace();
        std::cout << "操作成功！" << std::endl;
    }
    else {
        std::cout << "在屏幕上找不到匹配的图像" << std::endl;
    }

    return 0;
}
