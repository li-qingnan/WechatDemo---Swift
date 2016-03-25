//
//  BuddyListTableViewController.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import UIKit

class BuddyListTableViewController: UITableViewController,WXStatusDelegate,WXMessageDelegate,UIAlertViewDelegate{
    
    @IBOutlet weak var myStatus: UIBarButtonItem!
    // 好友未读消息数组  数据源
    var unreadList = [WXMessage]()
    
    // 好友状态数组  数据源
    var statusList = [WXStatus]()
    
    // 已登入
    var logged = false
    
    // 当前选择的聊天的好友的用户名
    var currentBuddyName = ""
    
    // 左边BtnItem 处理上下线
    @IBAction func leftBtnItemAction( sender: AnyObject) {
        // 根据当然在线状态, 调整title和进行上下线操作
        if logged{
            // 下线
            logout()
            myStatus.title = "离线"
        }else{
            // 上线
            login()
            myStatus.title = "在线"
        }
    }
    
    // 右边BtnItem 添加好友
    @IBAction func addBuddyAction(sender: AnyObject) {
        if logged{
            print("添加好友")
            
            let alertView = UIAlertController(title: "添加好友", message: "请输入用户名", preferredStyle: .Alert)
            // 创建文本框
            alertView.addTextFieldWithConfigurationHandler({ (textField : UITextField) -> Void in
                
            })
            
            let cancelAction  = UIAlertAction.init(title: "取消", style: .Default, handler: { (action :UIAlertAction ) -> Void in
                
            })
            
            let okAction  = UIAlertAction.init(title: "确定", style: .Default, handler: { (action :UIAlertAction ) -> Void in
                let textField = (alertView.textFields?.first)! as UITextField
                let buddyStr = textField.text
                self.getAppDelegate().addFriendSubscribe(buddyStr!)
            })
            
            alertView.addAction(cancelAction)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
    }
    
    // 获取总代理
    func getAppDelegate() ->AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    // 登入
    func login(){
        // 清空未读和状态数组
        unreadList.removeAll(keepCapacity: false)
        statusList.removeAll(keepCapacity: false)
        
        getAppDelegate().connect()
        // 导航左边btn改为在线状态
        myStatus.title = "在线"
        logged = true

        // 导航标题改成 "xxx"的好友
        // 取用户名
        let myID = NSUserDefaults.standardUserDefaults().stringForKey("weixinID")
        self.navigationItem.title = myID! + "的好友"
        
        
        // 通知表格更新数据
        self.tableView.reloadData()
    }
    
    // 登出
    func logout(){
        // 清空未读和状态数组
        unreadList.removeAll(keepCapacity: false)
        statusList.removeAll(keepCapacity: false)
        
        getAppDelegate().disConnect()
        // 导航左边btn改为下线状态
        myStatus.title = "离线"
        logged = false
        
        // 通知表格更新数据
        self.tableView.reloadData()
    }
    
    func loginAndSettingDelegate() {
        // 取用户名
        let myID = NSUserDefaults.standardUserDefaults().stringForKey("weixinID")
        
        // 去自动登录
        let autoLogin = NSUserDefaults.standardUserDefaults().boolForKey("wxautoLogin")
        
        // 如果配置了用户名和自动登录, 开始登录
        if(myID != nil && autoLogin){
            
            self.login()
            
        }else{ // 否则跳转到登录视图
            self.performSegueWithIdentifier("LoginSegue", sender: self)
        }
        
        // 接管状态代理
        getAppDelegate().statusDelegate = self
    }
    
    //MARK: - ------- WXMessageDelegate
    
    // 收到离线或未读
    func newMsg(aMsg: WXMessage) {
        // 如果消息有正文
        if aMsg.body != ""{
            // 则加入到未读消息中
            unreadList.append(aMsg)
            // 刷新表格
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - ------- WXStatusDelegate
    
    // 自己离线
    func meOff() {
        logout()
    }
    
    // 上线状态处理
    func isOn(status: WXStatus) {
        // 逐条查找
        for (index, oldStatus) in statusList.enumerate(){
            // 如果找到旧的用户的状态
            if(status.name == oldStatus.name){
                // 就移除掉旧的用户状态
                statusList.removeAtIndex(index)
                // 一旦找到, 就不找了, 退出循环
                break
            }
        }
        
        // 添加新状态到状态数组
        statusList.append(status)
        // 刷新列表
        self.tableView.reloadData()
    }
    
    // 下线状态处理
    func isOff(status: WXStatus) {
        // 逐条查找
        for (index, oldStatus) in statusList.enumerate(){
            // 如果找到旧的用户的状态
            if(status.name == oldStatus.name){
                // 更改旧的用户状态, 为下线
                statusList[index].isOnline = false
                // 一旦找到, 就不找了, 退出循环
                break
            }
        }

        // 刷新列表
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 登录 并且设置消息和状态代理
        loginAndSettingDelegate()
    }
    
    override func viewDidAppear(animated: Bool) {
        // 接管消息代理
        getAppDelegate().messsageDelagate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return statusList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("buddyListCell", forIndexPath: indexPath)

        // 好友的名称
        let name = statusList[indexPath.row].name
        
        // 好友状态
        let wxstutas = statusList[indexPath.row]
        var isOnlineStr = ""
        var statusColor : UIColor?
        if wxstutas.isOnline{
            isOnlineStr = "在线"
            statusColor = UIColor.greenColor()
        }else{
            isOnlineStr = "离线"
            statusColor = UIColor.grayColor()
        }
        
        // 未读消息的条数
        var unreadConuts = 0
        
        // 查找相应好友的未读条数
        for msg in unreadList{
            if name == msg.from{ // 如果name等于未读消息的name 未读数+1
                unreadConuts++
            }
        }
        
        let statusNameText = isOnlineStr + "   " + name + "(\(unreadConuts))"
        let attributStr : NSMutableAttributedString?
        attributStr = NSMutableAttributedString.init(string: statusNameText)
        let range : NSRange?
        range = NSRange.init(location: 0, length: 2)
        attributStr?.addAttribute(NSForegroundColorAttributeName, value: statusColor!, range: range!)
         
        cell.textLabel?.attributedText = attributStr

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 保存好友用户名
        currentBuddyName = statusList[indexPath.row].name 
        
        // 跳转到聊天视图
        self.performSegueWithIdentifier("toChatSegue", sender: self)
    }
    
    // 删除cell
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete{
//            unreadList.removeAtIndex(indexPath.row)
            // 删除好友
            getAppDelegate().deleteBuddy(statusList[indexPath.row].name)
            statusList.removeAtIndex(indexPath.row)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // 判断是否转到聊天页面
        if(segue.identifier == "toChatSegue"){
            let chatVC = segue.destinationViewController as! ChatTableViewController
            
            // 把当前单元格的用户名传递给聊天视图
            chatVC.toBuddyName = currentBuddyName
            
            // 把未读消息传递给聊天视图
            for msg in unreadList{
                
                // 如果来源name 等于 当前聊天好友的name
                if msg.from == currentBuddyName{
                    // 加入到聊天视图的消息组中
                    chatVC.msgList.append(msg)
                }
            }
            
            // 把相应的未读消息从 未读消息数组中移除
//            removeValueFromArray(currentBuddyName, aArray: &unreadList)
            // Array系统筛选方法
            unreadList = unreadList.filter{$0.from != self.currentBuddyName}
            
            // 刷新表格
            self.tableView.reloadData()
        }
    }
    
    
    // 反向过度
    @IBAction func unwindForSegue(segue: UIStoryboardSegue) {
        // 如果是登录界面完成按钮点击了, 开始登录
        let source = segue.sourceViewController as! LoginViewController
        
        // 如果Login页面需要登录
        if source.requireLogin{
            // 注销前一个用户
            logout()
            
            // 登录一个新用户
            login()
        }
    }
}
