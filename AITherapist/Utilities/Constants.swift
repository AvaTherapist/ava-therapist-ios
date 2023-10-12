//
//  Constants.swift
//  AITherapist
//
//  Created by cyrus refahi on 10/11/23.
//

import Foundation


struct Constants {
    static let test = true
    static let WebProtocol = test ? "http://" : "https://"
    static let BaseUrl = test ? "localhost" : "aitherapist.online"
    static let port = ":3000/"
    static private let sendConversationUrl = "/therapistAnswer"
    static let SendConversationUrl: String = BaseUrl + sendConversationUrl
    static let MainUrl = WebProtocol + BaseUrl + port
}
