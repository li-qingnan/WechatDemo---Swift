//
//  WXMessageDelegate.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/15.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import Foundation

// 消息代理协议
protocol WXMessageDelegate{
   func newMsg(aMsg:WXMessage)     // 一条消息
}