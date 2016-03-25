//
//  ChatTableViewController.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController,WXMessageDelegate {

    @IBOutlet weak var msgTF: UITextField!
    
    // 聊天的好友用户名
    var toBuddyName = ""
    // 聊天消息记录数组  数据源
    var msgList = [WXMessage]()
    
    // 发送自己正在输入状态
    @IBAction func composingAction(sender: AnyObject) {
        
        // 构建XML元素 message
        let xmlMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        
        // 增加属性
        xmlMessage.addAttributeWithName("to", stringValue: toBuddyName)
        xmlMessage.addAttributeWithName("from", stringValue: NSUserDefaults.standardUserDefaults().stringForKey("weixinID"))
        // 构建正在输入
        let composing = DDXMLElement.elementWithName("composing") as! DDXMLElement
        composing.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/chatstates")
        
        // 消息的子节点中加入正文
        xmlMessage.addChild(composing)
        
        // 通过通道发送XML文本
        getAppDelegate().xs!.sendElement(xmlMessage)
    }
    // 发送消息
    @IBAction func sendAction(sender: AnyObject) {
        // 获取聊天框文本
        let msgStr = msgTF.text
        
        // 如果文本不为空
        if(!msgStr!.isEmpty){
            // 构建XML元素 message
            let xmlMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
            
            // 增加属性
            xmlMessage.addAttributeWithName("type", stringValue: "chat")
            xmlMessage.addAttributeWithName("to", stringValue: toBuddyName)
            xmlMessage.addAttributeWithName("from", stringValue: NSUserDefaults.standardUserDefaults().stringForKey("weixinID"))
            
            // 构建正文
            let body = DDXMLElement.elementWithName("body") as! DDXMLElement
            body.setStringValue(msgStr)
            
            // 消息的子节点中加入正文
            xmlMessage.addChild(body)
            
            // 通过通道发送XML文本
            getAppDelegate().xs!.sendElement(xmlMessage)
            
            // 清空聊天框
            msgTF.text = ""
            
            // 保存自己的消息
            var meMsg = WXMessage()
            meMsg.isMe = true
            meMsg.body = msgStr!
            
            // 加入到聊天记录
            msgList.append(meMsg)
            
            // 刷新列表
            self.tableView.reloadData()
        }
    }
    
    // 获取总代理
    func getAppDelegate() ->AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getAppDelegate().messsageDelagate = self
    }
    
    //MARK: - ------- WXMessageDelegate
    
    // 收到消息
    func newMsg(aMsg: WXMessage) {
        
        // 对方正在输入
        if(aMsg.isComposing){
            self.navigationItem.title = "对方正在输入..."
            
        }else if (aMsg.body != ""){  // 如果消息有正文
            self.navigationItem.title = toBuddyName
            // 则加入到未读消息中
            msgList.append(aMsg)
            // 刷新表格
            self.tableView.reloadData()
        }
        
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
        return msgList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)
        
        // 获取对应的消息
        let msg = msgList[indexPath.row]
        
        // 对单元格文本 格式化
        if(msg.isMe){
            // 本人居右 灰色
            cell.textLabel?.textAlignment = .Right
            cell.textLabel?.textColor = UIColor.grayColor()
        }else{
            // 对方居左 橙色
            cell.textLabel?.textAlignment = .Left
            cell.textLabel?.textColor = UIColor.orangeColor()
        }
        
        // 设定单元格的文本
        cell.textLabel?.text = msg.body

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
