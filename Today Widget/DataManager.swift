//
//  DataManager.swift
//  Today Widget
//
//  Created by GJ on 15/8/8.
//  Copyright (c) 2015年 devgj. All rights reserved.
//

import Foundation

class DataManager {
    // MARK: Types
    
    private struct ManagerConstants {
        static let cacheKey = "TodayWidget.localDataKey"
        static let urlString = "http://c.m.163.com/nc/ioswidget/topicArticle.html"
    }
    
    // MARK: Properties
    
    private lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10
        return NSURLSession(configuration: configuration)
        }()
    
    private var dataTask: NSURLSessionDataTask?
    
    var cacheData: [NSDictionary]? {
        if let datas = NSUserDefaults.standardUserDefaults().valueForKey(ManagerConstants.cacheKey) as? [NSDictionary] {
            return datas
        }
        return nil
    }
    
    // MARK: Public Method
    
    /// 请求网络数据
    func requestDataWithCompletionHandler(completionHandler: (([NSDictionary]?, Bool) -> Void)?) {
        let url = NSURL(string: ManagerConstants.urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let body = "phoneid=dzci7p9T6yiDuHZCoRRGlXeJURjUshgGsEP0q83NB9hjFxdBoZYxPb9HeAUhRnFn&userid=Q1fXon/typpARiY6YKKRBexu5Qgz9IwfxBMkTUgNz7o="
        
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        dataTask?.cancel()
        
        dataTask = session.dataTaskWithRequest(request, completionHandler: { [weak self] (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            
            let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: nil)
            var datas: [NSDictionary]?
            var success = false
            if let dict = result as? NSDictionary {
                if let topicList = dict["topicList"] as? [NSDictionary] {
                    if topicList.count > 0 {
                        if let articleList = topicList[0]["articleList"] as? [NSDictionary] {
                            datas = articleList
                            NSUserDefaults.standardUserDefaults().setValue(datas, forKey: ManagerConstants.cacheKey)
                            NSUserDefaults.standardUserDefaults().synchronize()
                            success = datas?.count > 0
                        }
                    }
                }
            }
            
            completionHandler?(datas, success)
            
        })
        
        dataTask?.resume()
    }
}
