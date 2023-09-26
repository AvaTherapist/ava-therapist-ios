//
//  AppEnvironment.swift
//  AITherapist
//
//  Created by cyrus refahi on 9/2/23.
//

import UIKit
import Combine

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        /*
         To see the deep linking in action:
         
         1. Launch the app in iOS 13.4 simulator (or newer)
         2. Subscribe on Push Notifications with "Allow Push" button
         3. Minimize the app
         4. Drag & drop "push_with_deeplink.apns" into the Simulator window
         5. Tap on the push notification
         
         Alternatively, just copy the code below before the "return" and launch:
         
            DispatchQueue.main.async {
                deepLinksHandler.open(deepLink: .showCountryFlag(alpha3Code: "AFG"))
            }
        */
        let session = configuredURLSession()
        let webRepositories = configuredWebRepositories(session: session)
        let dbRepositories = configuredDBRepositories(appState: appState)
        let services = configuredServices(appState: appState,
                                                dbRepositories: dbRepositories,
                                                webRepositories: webRepositories)
        let diContainer = DIContainer(appState: appState, services: services)
        let deepLinksHandler = MainDeepLinksHandler(container: diContainer)
        let pushNotificationsHandler = MainPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
        let systemEventsHandler = MainSystemEventsHandler(
            container: diContainer, deepLinksHandler: deepLinksHandler,
            pushNotificationsHandler: pushNotificationsHandler,
            pushTokenWebRepository: webRepositories.pushTokenWebRepository)
        
        return AppEnvironment(container: diContainer,
                              systemEventsHandler: systemEventsHandler)
    }
    
    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }

    
    private static func configuredWebRepositories(session: URLSession) -> DIContainer.WebRepositories {
        let baseURL: String = "http://localhost:3000/"//"https://aitherapist.online:3000/"

//        let countriesWebRepository = RealCountriesWebRepository(
//            session: session,
//            baseURL: "https://restcountries.com/v2")
//        let imageWebRepository = RealImageWebRepository(
//            session: session,
//            baseURL: "https://ezgif.com")
        
        let authenticationWebRepository = MainAuthenticateRepository(baseURL: baseURL)
        let pushTokenWebRepository = RealPushTokenWebRepository(
            session: session,
            baseURL: "https://fake.backend.com")
        let conversationWebRepository = MainConversationRepository(baseURL: baseURL)
        let insightWebRepository = MainIsightRepository(baseURL: baseURL)
        return .init(conversationRepository: conversationWebRepository, pushTokenWebRepository: pushTokenWebRepository, authenticationRepository: authenticationWebRepository, insightRepository: insightWebRepository)
    }
    
    private static func configuredDBRepositories(appState: Store<AppState>) -> DIContainer.DBRepositories {
//        let persistentStore = CoreDataStack(version: CoreDataStack.Version.actual)
        let conversationDBRepository = MainConversationDBRepository()
        let userDBRepository = MainUserDBRepository()
        let insightDBRepository = MainInsightDBRepository()
        return .init(conversationRepository: conversationDBRepository, userRepository: userDBRepository, insightRepository: insightDBRepository)
    }
    
    private static func configuredServices(appState: Store<AppState>,
                                           dbRepositories: DIContainer.DBRepositories,
                                           webRepositories: DIContainer.WebRepositories
    ) -> DIContainer.Services {
        let conversationService = MainConversationService(conversationRepository: webRepositories.conversationRepository, appState: appState, conversationDBRepository: dbRepositories.conversationRepository)
        let insightService = MainInsightService(insightRepository: webRepositories.insightRepository, appState: appState, conversationDBRepository: dbRepositories.insightRepository)
        let authenticationService = MainAuthenticateService(appState: appState, authenticateRepository: webRepositories.authenticationRepository, userDBRepository: dbRepositories.userRepository)
        let userPermissionsService = MainUserPermissionsService(
            appState: appState, openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            })
        
        
        return .init(conversationService: conversationService, userPermissionsService: userPermissionsService, authenticationService: authenticationService, insightService: insightService)
    }
}

extension DIContainer {
    struct WebRepositories {
//        let imageRepository: ImageWebRepository
        let conversationRepository: ConversationRepository
        let pushTokenWebRepository: PushTokenWebRepository
        let authenticationRepository: AuthenticateRepository
        
        let insightRepository: InsightRepository
    }

    struct DBRepositories {
        let conversationRepository: ConversationDBRepository
        let userRepository: UserDBRepository
        let insightRepository: InsightDBRepository
    }
}
