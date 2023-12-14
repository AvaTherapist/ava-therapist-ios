//
//  ChatRepository.swift
//  AITherapist
//
//  Created by Cyrus Refahi on 10/12/23.
//

import Foundation
import Combine
import Alamofire

protocol ChatWebRepository: WebRepository {
    func loadChatsForConversation(conversationID: Int) -> AnyPublisher<LazyList<Chat>, Error>
    func sendChatToServer(data: SaveChatRequset) -> AnyPublisher<Chat, Error>
}

struct MainChatWebRepository: ChatWebRepository {
    var AFSession: Session
    
    var session: URLSession
    var bgQueue: DispatchQueue = Constants.bgQueue
    var baseURL: String
    
    static let ChatAPI = "chat"

    init(baseURL: String, session: URLSession) {
        self.baseURL = baseURL
        self.session = session
        self.AFSession = setAFSession(session, queue: bgQueue)
    }
    
    func sendChatToServer(data: SaveChatRequset) -> AnyPublisher<Chat, Error> {
        
        do {
            let parameters = try JSONEncoder().encode(data)
            let params = try JSONSerialization.jsonObject(with: parameters, options: []) as? [String: Any] ?? [:]
            let request: AnyPublisher<AddChatServerResponse, Error> = webRequest(api: API.addChat(params: params))
            
            return request
                .map{
                    Chat(message: $0.data.message!, conversationID: $0.data.conversationID!, chatSequence: nil, isUserMessage: false, isSentToserver: .NoStatus)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func loadChatsForConversation(conversationID: Int) -> AnyPublisher<LazyList<Chat>, Error> {
        
        let request: AnyPublisher<GetConversationChatServerResponse, Error> = webRequest(api: API.getConversationChats(conversationID: conversationID))
        
        return request
            .map{
                return $0.data.lazyList
            }
            .eraseToAnyPublisher()
    }
}

extension MainChatWebRepository {
    
    enum API: APICall {
        case getConversationChats(conversationID: Int)
        case addChat(params: Parameters? = nil)
        
        var url: String {
            switch self {
            case let .getConversationChats(conversationID):
                return "\(MainChatWebRepository.ChatAPI)/getConversationChat/\(conversationID)"
            case .addChat:
                return "\(MainChatWebRepository.ChatAPI)/addUserChat"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .getConversationChats:
                return .get
            case .addChat:
                return .post
            }
        }
        
        var headers: HTTPHeaders? {
            nil
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .getConversationChats:
                return URLEncoding.default
            case .addChat:
                return JSONEncoding.default
            }
        }
        
        var parameters: Parameters? {
            switch self {
            case .getConversationChats:
                return nil
            case let .addChat(params):
                return params
            }
        }
    }
}

