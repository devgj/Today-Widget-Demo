//
//  TodayViewController.swift
//  Today Widget
//
//  Created by GJ on 15/8/8.
//  Copyright (c) 2015年 devgj. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataManager: DataManager!
    
    private var datas: [NSDictionary]?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager = DataManager()
        datas = dataManager.cacheData
        println(datas)
        resetContentSize()
        requestData()
    }
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        println(defaultMarginInsets)
        var margin = defaultMarginInsets
        margin.bottom = 0
        return margin
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas?.count >= 3 {
            return 3
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let data = datas?[indexPath.row]
        cell.textLabel?.text = data?["title"] as? String
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let url = NSURL(string: "mynews://")
        extensionContext?.openURL(url!, completionHandler: nil)
    }
    
    // MARK: Convenience
    
    private func resetContentSize() {
        // 指定Today Widget内容的高度.
        preferredContentSize.height = 44 * 3
    }
    
    private func requestData() {
        dataManager.requestDataWithCompletionHandler { [weak self] (datas: [NSDictionary]?, success: Bool) -> Void in
            if self == nil { return }
            // 注意: 回到主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if success {
                    self!.datas = datas
                    self!.tableView.reloadData()
                }
            })
        }
    }
}
