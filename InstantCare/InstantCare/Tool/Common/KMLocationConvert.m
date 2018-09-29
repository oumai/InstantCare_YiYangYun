//
//  KMLocationConvert.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/18.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMLocationConvert.h"
#import <Math.h>

static double LAT_OFFSET_0(double x, double y)
{
    return -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
}

static double LAT_OFFSET_1(double x)
{
    return (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
}

static double LAT_OFFSET_2(double y)
{
    return (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
}

static double LAT_OFFSET_3(double y)
{
    return (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
}

static double LON_OFFSET_0(double x, double y)
{
    return 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
}

static double LON_OFFSET_1(double x)
{
    return (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
}

static double LON_OFFSET_2(double x)
{
    return (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
}

static double LON_OFFSET_3(double x)
{
    return (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
}

static double RANGE_LON_MAX = 137.8347;
static double RANGE_LON_MIN = 72.004;
static double RANGE_LAT_MAX = 55.8271;
static double RANGE_LAT_MIN = 0.8293;
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
static double a = 6378245.0;
static double ee = 0.00669342162296594323;

/************************* Methods *****************************/
static double transformLat(double x, double y) {
    double ret = LAT_OFFSET_0(x, y);
    ret += LAT_OFFSET_1(x);
    ret += LAT_OFFSET_2(y);
    ret += LAT_OFFSET_3(y);
    return ret;
}

static double transformLon(double x, double y) {
    double ret = LON_OFFSET_0(x, y);
    ret += LON_OFFSET_1(x);
    ret += LON_OFFSET_2(x);
    ret += LON_OFFSET_3(x);
    return ret;
}

static bool outOfChina(double lat, double lon) {
    if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
        return true;
    if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
        return true;
    return false;
}

static CLLocationCoordinate2D gcj02Encrypt(double ggLat, double ggLon)
{
    CLLocationCoordinate2D resPoint;
    double mgLat;
    double mgLon;
    if (outOfChina(ggLat, ggLon)) {
        resPoint.latitude = ggLat;
        resPoint.longitude = ggLon;
        return resPoint;
    }
    double dLat = transformLat((ggLon - 105.0), (ggLat - 35.0));
    double dLon = transformLon((ggLon - 105.0), (ggLat - 35.0));
    double radLat = ggLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;
    
    resPoint.latitude = mgLat;
    resPoint.longitude = mgLon;
    return resPoint;
}

static CLLocationCoordinate2D gcj02Decrypt(double gjLat, double gjLon)
{
    CLLocationCoordinate2D gPt = gcj02Encrypt(gjLat, gjLon);
    double dLon = gPt.longitude - gjLon;
    double dLat = gPt.latitude - gjLat;
    CLLocationCoordinate2D pt;
    pt.latitude = gjLat - dLat;
    pt.longitude = gjLon - dLon;
    return pt;
}

static CLLocationCoordinate2D bd09Decrypt(double bdLat, double bdLon)
{
    CLLocationCoordinate2D gcjPt;
    double x = bdLon - 0.0065, y = bdLat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    gcjPt.longitude = z * cos(theta);
    gcjPt.latitude = z * sin(theta);

    return gcjPt;
}

static CLLocationCoordinate2D bd09Encrypt(double ggLat, double ggLon)
{
    CLLocationCoordinate2D bdPt;
    double x = ggLon, y = ggLat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    bdPt.longitude = z * cos(theta) + 0.0065;
    bdPt.latitude = z * sin(theta) + 0.006;
    return bdPt;
}

/**
 * @brief 世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *        ####只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
 *
 * @param location
 *            世界标准地理坐标(WGS-84)
 *
 * @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
CLLocationCoordinate2D wgs84ToGcj02(CLLocationCoordinate2D location)
{
    return gcj02Encrypt(location.latitude, location.longitude);
}

/**
 * @brief 中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *        ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 * @param location
 *            中国国测局地理坐标（GCJ-02）
 *
 * @return 世界标准地理坐标（WGS-84）
 */
CLLocationCoordinate2D gcj02ToWgs84(CLLocationCoordinate2D location)
{
    return gcj02Decrypt(location.latitude, location.longitude);
}

/**
 * @brief 世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 *
 * @param location
 *            世界标准地理坐标(WGS-84)
 *
 * @return 百度地理坐标（BD-09)
 */
CLLocationCoordinate2D wgs84ToBd09(CLLocationCoordinate2D location)
{
    CLLocationCoordinate2D gcj02Pt = gcj02Encrypt(location.latitude, location.longitude);
    return bd09Encrypt(gcj02Pt.latitude, gcj02Pt.longitude);
}

/**
 * @brief 中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 *
 * @param location
 *            中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 * @return 百度地理坐标（BD-09)
 */
CLLocationCoordinate2D gcj02ToBd09(CLLocationCoordinate2D location)
{
    return bd09Encrypt(location.latitude, location.longitude);
}

/**
 * @brief 百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 * @param location
 *            百度地理坐标（BD-09)
 *
 * @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
CLLocationCoordinate2D bd09ToGcj02(CLLocationCoordinate2D location)
{
    return bd09Decrypt(location.latitude, location.longitude);
}

/**
 * @brief 百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 *
 *        ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 * @param location
 *            百度地理坐标（BD-09)
 *
 * @return 世界标准地理坐标（WGS-84）
 */
CLLocationCoordinate2D bd09ToWgs84(CLLocationCoordinate2D location)
{
    CLLocationCoordinate2D gcj02 = bd09ToGcj02(location);
    return gcj02Decrypt(gcj02.latitude, gcj02.longitude);
}

