//
//  WXStatusDelegate.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/15.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import Foundation

// 状态代理协议
protocol WXStatusDelegate{
    func isOn(status:WXStatus)     // 上线
    func isOff(status:WXStatus)    // 下线
    func meOff()    // 自己下线
}