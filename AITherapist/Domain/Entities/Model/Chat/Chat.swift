//
//  Chat.swift
//  AITherapist
//
//  Created by cyrus refahi on 9/2/23.
//

import Foundation
import RealmSwift

struct GetConversationChatServerResponse: Decodable {
    var code: Int
    var message: String
    var chats: [Chat]
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case code = "code"
        case chats = "chat"
    }
}

struct AddChatServerResponse: Decodable, ServerResponseData {
    
    var message: String?
    var code: Int?
    var data: AddChatServerResponseData
    
    struct AddChatServerResponseData: Decodable {
        var message: String?
        var conversationID: Int?
        var transcription: String?
    }
}

struct SaveChatRequset: Encodable{
    var chat: SaveChatRequsetBody
}

struct SaveChatRequsetBody: Encodable {
    var message: String
    var conversationID: Int
}

enum ChatServerState: String, PersistableEnum {
    case BeingSent
    case ErrorWhileSending
    case NoStatus
}

class Chat: Object, Codable, Identifiable {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var message: String
    @Persisted var conversationID: Int
    
    @Persisted var chatSequence: Int?
    @Persisted var isUserMessage: Bool
    @Persisted var isSentToServer: ChatServerState?
//    @Persisted var dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "chatID"
        case message = "message"
        case conversationID = "conversationID"
        case chatSequence = "chatsequence"
        case isUserMessage = "isUserMessage"
//        case dateCreated = "DateCreated"
    }
    
    init(message: String, conversationID: Int, chatSequence: Int?, isUserMessage: Bool, isSentToserver: ChatServerState?){
        super.init()
        self.id = DataBaseManager.Instance.IncrementaChatID()
        self.message = message
        self.conversationID = conversationID
        
        self.chatSequence = chatSequence
        self.isUserMessage = isUserMessage
        self.isSentToServer = isSentToserver
//        self.dateCreated = dateCreated
    }
    
    
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self , forKey: .id)
        
        message = try container.decode(String.self , forKey: .message)
        conversationID = try container.decode(Int.self , forKey: .conversationID)
        chatSequence = try container.decode(Int?.self , forKey: .chatSequence)
        isUserMessage = try container.decode(Bool.self , forKey: .isUserMessage)
        isSentToServer = .NoStatus
//        dateCreated = try container.decode(Date.self , forKey: .dateCreated)
    }
    
}
