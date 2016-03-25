//
//  LoginViewController.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var hostTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var autoLoginSwitch: UISwitch!
    
    // 需要登录
    var requireLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(sender: AnyObject) {
        getAppDelegate().registerAccount(passwordTF.text!)
    }

    // 获取总代理
    func getAppDelegate() ->AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as! UIBarButtonItem == self.doneBtn{
            NSUserDefaults.standardUserDefaults().setObject(userTF.text, forKey: "weixinID")
            NSUserDefaults.standardUserDefaults().setObject(passwordTF.text, forKey: "weixinPwd")
            NSUserDefaults.standardUserDefaults().setObject(hostTF.text, forKey: "wxServer")
            
            // 配置自动登录
            NSUserDefaults.standardUserDefaults().setBool(self.autoLoginSwitch.on, forKey: "wxautoLogin")
            // 同步用户配置
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // 需要登录
            requireLogin = true
        }
    }


}
