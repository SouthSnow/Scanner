//
//  Api.swift
//  Scanner
//
//  Created by swifter on 2018/10/18.
//  Copyright © 2018 pfl. All rights reserved.
//

import Foundation

let BaseURL = "http://api.kdniao.cc/Ebusiness/EbusinessOrderHandle.aspx"
let appKey = "c0f9d5b0-1d9b-48e7-a6b7-e9348d9d29be"
let EBusinessID = "1273901"

/// 订单轨迹
let expressTraceApi = "1002"
/// 订单识别
let orderIdentifyApi = "2002"


func toJSONSting(_ withDic:[String: String]) -> String {
    var jsonStr = withDic.reduce("{") { (origin, dic) -> String in
            let jsonString = origin + "\"" + dic.key + "\"" + ":" + "\"" + dic.value + "\","
            return jsonString
        }
    jsonStr.removeLast()
    jsonStr.append("}")
    return jsonStr
}

extension Dictionary {
    
    public var toJSONString: String  {
        get {
            guard let dic = self as? [String:String] else {return ""}
            var jsonStr = dic.reduce("{") { (origin, dic) -> String in
                let jsonString = origin + "\"" + dic.key + "\"" + ":" + "\"" + dic.value + "\","
                return jsonString
            }
            jsonStr.removeLast()
            jsonStr.append("}")
            return jsonStr
        }
    }

}

























