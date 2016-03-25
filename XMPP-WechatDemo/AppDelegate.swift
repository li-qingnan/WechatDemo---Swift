//
//  AppDelegate.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,XMPPStreamDelegate,XMPPRosterDelegate {

    var window: UIWindow?
    
    // 通信流通道
    var xs: XMPPStream?
    
    // 好友花名册
    var roster: XMPPRoster?
    
    // 服务器是否开启
    var isOpen = false
    // 密码
    var pwd = ""
    // 状态代理
    var statusDelegate: WXStatusDelegate?
    // 消息代理
    var messsageDelagate: WXMessageDelegate?
    
//MARK: - ------- 收到状态
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        
        // 自己的用户名
        let myUser = sender.myJID.user
        
        // 好友的用户名
        let friendUser = presence.from().user
        
        // 用户所在的域
        let domain = presence.from().domain
        
        // 状态类型
        let statusType = presence.type()
        
        // 如果收到添加好友时, statusType = error 和 friendUser为空, 不处理这个用户
        if statusType != "error" && friendUser != nil{
            // 如果状态不是自己的
            if(friendUser != myUser){
                
                // 状态保存的结构
                var status = WXStatus()
                
                // 保存了状态完整的用户名
                status.name = friendUser + "@" + domain
                
                // 上线
                if statusType == "available"{
                    status.isOnline = true
                    statusDelegate?.isOn(status)
                    
                }else if statusType == "unavailable"{  // 下线
                    status.isOnline = false
                    statusDelegate?.isOff(status)
                }
            }
        }
    }
    
//MARK: - ------- 收到消息
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        // 如果是聊天消息
        if message.isChatMessage(){
            var msg = WXMessage()
            
            // 对方正在输入
            if message.elementForName("composing") != nil{
                msg.isComposing = true
            }
            // 离线消息
            if message.elementForName("delay") != nil{
                msg.isDelay = true
            }
            
            // 消息正文
            if let body = message.elementForName("body"){
                msg.body = body.stringValue()
            }
            
            // 完整用户名
            msg.from = message.from().user + "@" + message.from().domain
            
            // 添加到消息代理中
            messsageDelagate?.newMsg(msg)
        }
    }
    
//MARK: - ------- 建立通道
    func createStream(){
        xs = XMPPStream()
        xs?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        // 创建花名册
        createRoster()
    }
//MARK: - ------- 创建花名册
    func createRoster(){
        let rosterStorage:XMPPRosterCoreDataStorage = XMPPRosterCoreDataStorage.sharedInstance()
        roster = XMPPRoster(rosterStorage: rosterStorage, dispatchQueue: dispatch_get_main_queue())
        roster?.autoAcceptKnownPresenceSubscriptionRequests = true
        roster?.autoFetchRoster = true
        roster?.activate(xs)
        roster?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
//MARK: - ------- 发送上线状态
    func goOnline(){
        let p = XMPPPresence()
        xs?.sendElement(p)
    }
//MARK: - ------- 发送下线状态
    func goOffline(){
        let p = XMPPPresence(type: "unavailabe")
        xs?.sendElement(p)
    }
//MARK: - ------- 连接服务(查看服务器是否可连接)
    func connect() -> Bool{
        // 建立通道
        createStream()
        
        // 通道已经连接
        if xs!.isConnected(){
            return true
        }
        
        let user = NSUserDefaults.standardUserDefaults().stringForKey("weixinID")
        let password = NSUserDefaults.standardUserDefaults().stringForKey("weixinPwd")
        let server = NSUserDefaults.standardUserDefaults().stringForKey("wxServer")
        
        if (user != nil && password != nil){
            // 通道用户名
            xs!.myJID = XMPPJID.jidWithString(user!)
            // 服务器名
            xs!.hostName = server!
            // 密码保存备用
            pwd = password!
            
            // 连接
            try! xs!.connectWithTimeout(5000)
            
        }
        
        return false
    }
    
//MARK: - ------- 断开连接
    func disConnect(){
        if xs != nil{
            if xs!.isConnected(){ //如果在连接状态才下线
                // 下线
                goOffline()
                // 断开
                xs?.disconnect()
            }
        }
    }
    
//MARK: - ------- XMPPStreamDelegate
    
    // 连接成功
    func xmppStreamDidConnect(sender: XMPPStream!) {
        isOpen = true
        // 验证密码
        try! xs!.authenticateWithPassword(pwd)
    }
    
    // 验证成功
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        // 上线
        goOnline()
    }
    
//MARK: - ------- XMPPRosterDelegate
    // 添加好友
    func addFriendSubscribe(name: String){
        let jid: XMPPJID = XMPPJID.jidWithString(name + "@" + "yinandemacbook-pro.local")
        roster?.subscribePresenceToUser(jid)
    }
    
    // 删除好友
    func deleteBuddy(name: String){
        // 正常格式JID Username @ Domain(域名) /  resource(客户端来源)
        /* let jidStr = name + "@" + "yinandemacbook-pro.local" */
        
        // 此处不明白为何只传Name就可以
        let jid = XMPPJID.jidWithString(name)
        
        roster?.removeUser(jid)
    }
    
    // 收到好友请求
    func xmppRoster(sender: XMPPRoster!, didReceivePresenceSubscriptionRequest presence: XMPPPresence!) {
        
        // 取得好友状态
        let presenceType = presence.type() as String // online Or offline
        
        // 请求的用户
        let presenceFromUser = presence.from().user
        let jid:XMPPJID = XMPPJID.jidWithString(presenceFromUser + "@" + "yinandemacbook-pro.local") as XMPPJID
        
        // 如果状态是订阅 提醒是否添加好友
        if presenceType == "subscribe"{
        
            let message = "是否添加" + presenceFromUser + "为好友"
            let alertView = UIAlertController(title: "好友请求", message: message, preferredStyle: .Alert)
            
            let cancelAction  = UIAlertAction.init(title: "取消", style: .Default, handler: { (action :UIAlertAction ) -> Void in
                
            })
            
            
            let okAction  = UIAlertAction.init(title: "确定", style: .Default, handler: { (action :UIAlertAction ) -> Void in
                self.roster?.acceptPresenceSubscriptionRequestFrom(jid, andAddToRoster: true)
            })
            
            alertView.addAction(cancelAction)
            alertView.addAction(okAction)
            
            self.window?.rootViewController?.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    // 注册账号
    func registerAccount(pwd: String){
       try! xs?.registerWithPassword(pwd)
    }
    
    // 注册账号成功
    func xmppStreamDidRegister(sender: XMPPStream!) {
        
    }
    // 注册账号失败
    func xmppStream(sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

