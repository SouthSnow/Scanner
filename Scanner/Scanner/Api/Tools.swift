//
//  File.swift
//  Scanner
//
//  Created by swifter on 2018/10/28.
//  Copyright © 2018 pfl. All rights reserved.
//

import Foundation
import CommonCrypto

struct ExpressModel {
    let exname: String?, img: String?, com: String?, exid: String?, phone: String?
}

extension String {
    var md5: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = data(using: .utf8) {
            data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                CC_MD5(bytes, CC_LONG(data.count), &digest)
            }
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension String {
    var pureNumberString: Bool {
        var pure = false
        let scan = Scanner(string: self)
        var result = 0
        pure = scan.scanInt(&result) && scan.isAtEnd
        return pure
    }
}


protocol ExpressCreatable {
    init(dictionary:[String: String])
}

struct ExpressTrace:ExpressCreatable {
    let AcceptStation: String
    let AcceptTime: String
    init(dictionary:[String: String]) {
        AcceptTime = dictionary["AcceptTime"] ?? ""
        AcceptStation = dictionary["AcceptStation"] ?? ""
    }
}

/// 哪家快递公司
struct ExpressCompany:ExpressCreatable {
    let ShipperCode: String
    let ShipperName: String
    init(dictionary: [String : String]) {
        self.ShipperCode = dictionary["ShipperCode"] ?? ""
        self.ShipperName = dictionary["ShipperName"] ?? ""
    }
}
