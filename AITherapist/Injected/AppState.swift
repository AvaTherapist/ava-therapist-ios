//
//  AppState.swift
//  AITherapist
//
//  Created by Cyrus Refahi on 9/2/23.
//


import SwiftUI
import Combine

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
    var permissions = Permissions()
    var conversationData = ConversationData()
}

extension AppState {
    class UserData: Equatable, ObservableObject{
        static func == (lhs: AppState.UserData, rhs: AppState.UserData) -> Bool {
            lhs.user == rhs.user
        }
        
        @Published var user: Loadable<User> = .notRequested
        @Published var insight: Loadable<Insight> = .notRequested
        /*
         The list of countries (Loadable<[Country]>) used to be stored here.
         It was removed for performing countries' search by name inside a database,
         which made the resulting variable used locally by just one screen (CountriesList)
         Otherwise, the list of countries could have remained here, available for the entire app.
         */
    }
}

extension AppState{
    class ConversationData: ObservableObject{
        @Published var conversations: Loadable<LazyList<Conversation>> = .notRequested
        
        init(conversations: Loadable<LazyList<Conversation>> = .notRequested) {
            self.conversations = conversations
        }
    }
}

extension AppState {
    struct ViewRouting: Equatable {
//        var user = User.R
//        var countriesList = CountriesList.Routing()
//        var countryDetails = CountryDetails.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
        var keyboardHeight: CGFloat = 0
    }
}

extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
    }
    
    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData &&
        lhs.routing == rhs.routing &&
        lhs.system == rhs.system &&
        lhs.permissions == rhs.permissions
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
#endif
