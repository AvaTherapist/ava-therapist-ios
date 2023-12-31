//
//  Quote.swift
//  AITherapist
//
//  Created by Cyrus Refahi on 9/24/23.
//

import Foundation
import RealmSwift


class Quote: EmbeddedObject, Decodable {
    
    @Persisted var quote: String
    
    enum CodingKeys: String, CodingKey {
        case quote = "quote"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quote = try container.decode(String.self , forKey: .quote)
    }
}
