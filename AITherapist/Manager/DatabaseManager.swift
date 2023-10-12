//
//  DatabaseManager.swift
//  AITherapist
//
//  Created by cyrus refahi on 3/4/23.
//

import Foundation
import RealmSwift
import Combine

protocol DataBase {
    func GetAll<T: RealmFetchable>() -> LazyList<T>
    func GetCount<T: RealmFetchable>(value: T.Type) -> Int
    func Write<T: Object>(writeData: T) -> AnyPublisher<Void, Error>
    func DeleteAndWrite<T: Object>(data: T) -> AnyPublisher<Void, Error>
    func EntityExist<Element: Object>(id: Int, ofType: Element.Type) -> Bool
}

class DataBaseManager: DataBase {
    
    func GetAll<T: RealmFetchable>() -> LazyList<T> {
        return realm.objects(T.self).lazyList
    }
    
    func GetCount<T: RealmFetchable>(value: T.Type) -> Int {
        return realm.objects(T.self).lazyList.count
    }
    
    func EntityExist<Element: Object>(id: Int, ofType: Element.Type) -> Bool{
        return realm.object(ofType: ofType, forPrimaryKey: id) != nil
    }
    
    func DeleteAndWrite<T: Object>(data: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> {  promise in
            
            do {
                try self.realm.write {
                    self.realm.delete(data)
                    self.realm.add(data)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func Write<T: Object>(writeData: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> {  promise in
            do {
                try self.realm.write {
                    self.realm.add(writeData)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    static let Instance = DataBaseManager()
    private let realm: Realm
    private var cancellable: AnyCancellable?
    
    init() {
        realm = try! Realm()
    }
    
    func getDB() -> Realm {
        return realm
    }
    
    func hasLoadedUser() -> AnyPublisher<Bool, Error> {
        let userCount = realm.objects(User.self).count
        return Just(userCount > 0)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func readUser() -> AnyPublisher<User, Error> {
        let user = Array(realm.objects(User.self))
        
        if user.count == 0 {
            return Fail(error: DataBaseError.UserIsNil)
                .eraseToAnyPublisher()
        }
        
        return Just(user.first!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func writeUserData(user: User) -> AnyPublisher<Void, Error>{
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataBaseError.SelfIsNil))
                return
            }
            
            if !self.userExists(id: user.id)  {
                do {
                    try self.realm.write {
                        self.realm.add(user)
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            } else {
                do {
                    try self.realm.write {
                        self.realm.delete(user)
                        self.realm.add(user)
                    }
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //
    func readRecipeDatas() -> Conversation{
        return Array(realm.objects(Conversation.self))[0]
    }
    //
    func deleteConversation(conversation: Conversation) {
        realm.delete(conversation)
    }
    
    func deleteUser(user: User) {
        realm.delete(user)
    }
    //
    //    func deleteRecipeDataByID(favRecipeID: Int) {
    //        if(favRecipeExist(id: favRecipeID)){
    //            try! realm.write {
    //                let favRecipe = realm.objects(FavRecipe.self).where {
    //                    $0.id == favRecipeID
    //                }
    //                realm.delete(favRecipe)
    //            }
    //        }
    //    }
    
    
    
    private func userExists(id: Int) -> Bool {
        return realm.object(ofType: Conversation.self, forPrimaryKey: id) != nil
    }
    
}

public enum DataBaseError: Error {
    case SelfIsNil
    case UserIsNil
}
