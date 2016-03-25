//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var locList = ["上海","南京","上海","大连","北京","上海"]
var numList = [0,7,11,23,77,7,-7,7]

// 获取正确的删除索引  <T: Equatable>泛型函数
func getRemoveIndex<T: Equatable>(value: T, aArray:[T]) -> [Int]{
    // 原index数组
    var indexArray = [Int] ()
    // 正确index数组
    var correctArray = [Int] ()
    
    // 获取指定值在数组中的索引并保存  aValue没用到用_代表
    for (index, /*aValue*/_) in aArray.enumerate(){
        if(value == aArray[index]){
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
func removeValueFromArray<T: Equatable>(value: T, inout aArray:[T]){
    var correctArray = [Int] ()
    
    correctArray = getRemoveIndex(value, aArray: aArray)
    
    // 从原数组中(用正确的索引)删除指定元素
    for index in correctArray{
        aArray.removeAtIndex(index)
    }
}


// 测试函数
removeValueFromArray("上海", aArray: &locList)
removeValueFromArray(7, aArray: &numList)
