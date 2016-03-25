//
//  WXMessage.swift
//  XMPP-WechatDemo
//
//  Created by Yinan on 16/3/14.
//  Copyright © 2016年 Yinan. All rights reserved.
//

import Foundation

// 好友消息结构
struct WXMessage {
    var body = ""           // 消息正文
    var from = ""           // 来源
    var isComposing = false     // 是否正在输入 (composing 写作字段)
    var isDelay = false     // 是否是离线消息
    var isMe = false        // 是否是自己发出的
}

// 状态
struct WXStatus {
    var name = ""           // 是谁
    var isOnline = false    // 上线还是下线
}


//MARK: - ------- 从数组中删除指定的元素
// 获取正确的删除索引
func getRemoveIndex(value: String, aArray:[WXMessage]) -> [Int]{
    // 原index数组
    var indexArray = [Int] ()
    // 正确index数组
    var correctArray = [Int] ()
    
    // 获取指定值在数组中的索引并保存  aValue没用到用_代表
    for (index, /*aValue*/_) in aArray.enumerate(){
        if(value == aArray[index].from){
            // 如果数组中找到指定的值, 则把索引添加到 索引数组
            indexArray.append(index)
        }
    }
    
    // 计算正确的删除索引
    for (index,originIndex) in indexArray.enumerate(){
        // 正确的索引
        var i = 0
        // 用指定值在原数组中的索引, 减去 索引数组中的索引
        i = originIndex - index
        
        // 添加到正确索引数组中
        correctArray.append(i)
    }
    
    // 返回正确的删除索引
    return correctArray
}

// 从数组中删除指定的元素  inout可改变aArray中的值
func removeValueFromArray(value: String, inout aArray:[WXMessage]){
    var correctArray = [Int] ()
    
    correctArray = getRemoveIndex(value, aArray: aArray)
    
    // 从原数组中(用正确的索引)删除指定元素
    for index in correctArray{
        aArray.removeAtIndex(index)
    }
}