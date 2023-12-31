//
//  Diary.swift
//  AITherapist
//
//  Created by Cyrus Refahi on 9/2/23.
//

import Foundation
import RealmSwift

class Diary: Object, Decodable {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var diaryMessage: String
    @Persisted var diaryName: String
    @Persisted var moodID: Int
    @Persisted var userID: Int
    @Persisted var summary: String
    @Persisted var dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "DiaryID"
        case diaryMessage = "DiaryMessage"
        case diaryName = "DiaryName"
        case moodID = "MoodID"
        case userID = "UserID"
        case summary = "Summary"
        case dateCreated = "DateCreated"
    }
    
    override init() {
        super.init()
    }
            
    init (id: Int, diaryMessage: String, diaryName: String, moodID: Int, userID: Int, summary: String, dateCreated: Date) {
        super.init()
        self.id = id
        self.diaryMessage = diaryMessage
        self.diaryName = diaryName
        self.moodID = moodID
        self.userID = userID
        self.summary = summary
        self.dateCreated = dateCreated
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self , forKey: .id)
        diaryMessage = try container.decode(String.self , forKey: .diaryMessage)
        diaryName = try container.decode(String.self , forKey: .diaryName)
        moodID = try container.decode(Int.self , forKey: .moodID)
        userID = try container.decode(Int.self , forKey: .userID)
        summary = try container.decode(String.self , forKey: .summary)
        dateCreated = try container.decode(Date.self , forKey: .dateCreated)
    }
    
}
