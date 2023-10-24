//
//  ConversationListView.swift
//  AITherapist
//
//  Created by cyrus refahi on 9/17/23.
//

import SwiftUI

struct ConversationListView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    //    @Namespace var conversationListNamespace
    //    @State var show = false
    
    var body: some View {
        mainContent
    }
    
    @ViewBuilder var mainContent: some View {
        switch self.viewModel.conversations {
        case .notRequested:
            notRequestedView
        case .isLoading(last: _, cancelBag: _):
            loadingView()
        case let .loaded(conversations):
            loadedView(conversations)
        case let .failed(error):
            failedView(error)
        case .partialLoaded(_):
            notRequestedView
        }
    }
}

// MARK: Loading Content
private extension ConversationListView {
    private var notRequestedView: some View {
        Text("").onAppear(perform: self.viewModel.loadConversationList)
    }
    
    private func loadingView() -> some View {
        CircleLoading()
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
#warning("Handle Conversation ERROR")
            print("Handle Conversation ERROR")
        })
    }
}

// MARK: Displaying Content
private extension ConversationListView {
    func loadedView(_ conversationList: LazyList<Conversation>) -> some View {
        NavigationStack {
            Button {
                self.viewModel.createNewConversation()
            } label: {
                Text("Create new conversation")
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundStyle(.green)
                            .padding(2)
                    )
                    .foregroundColor(.white)
            }
            
            ZStack{
                List{
                    ForEach (conversationList, id: \.id){ conversation in
                        NavigationLink {
                            TherapyChatView(viewModel: .init(conversation: conversation, container: self.viewModel.container))
                        } label: {
                            ConversationCell(conversation: conversation)
                        }
                        .onAppear {
                            self.viewModel.loadMore()
                        }
                    }
                    .onDelete(perform: self.viewModel.deleteConversation)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(width: UIViewController().view.bounds.width)
            }
        }
    }
}

extension ConversationListView{
    struct ConversationCell: View {
        var conversation: Conversation
        
        var body: some View {
            cellView
        }
        
        @ViewBuilder private var cellContent: some View{
            VStack{
                Text(conversation.conversationName)
                    .font(.title2)
                    .padding([.leading], 8)
                    .lineLimit(1)
                Text(getDateString())
                    .font(.subheadline)
                    .padding([.trailing], 8)
            }
        }
        
        @ViewBuilder private var cellView: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 25)
                    .padding([.leading, .trailing], 16)
                    .frame(height: 250)
                    .foregroundStyle(ColorPallet.SecondaryColorGreen)
                cellContent
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding([.leading, .trailing], 16)
                    .padding([.top], 16)
            }
        }
        
        private func getDateString() -> String {
            let components = conversation.dateCreated.get(.month, .day, .year)
            if let day = components.day, let month = components.month, let year = components.year {
                return "\(day)-\(month)-\(year)"
            }
            
            return ""
        }
    }
}

extension ConversationListView {
    class ViewModel: ObservableObject {
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()
        
        @Published var conversations: Loadable<LazyList<Conversation>>
        //        @Published var conversationList: [Conversation] = []
        
        private var listIndex = 0
        
        init(coninater: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests, conversations: Loadable<LazyList<Conversation>> = .notRequested) {
            self.container = coninater
            
            self.isRunningTests = isRunningTests
            _conversations = .init(initialValue: conversations)
        }
        
        func loadConversationList() {
            container.services.conversationService.loadConversationList(conversations: loadableSubject(\.conversations))
        }
        
        func createNewConversation() {
            self.container.services.conversationService.createNewConversation()
                .breakpoint()
                .sink { error in
#warning("Handle Error")
                    print("Error while creating new conversation \(error)")
                } receiveValue: {
                    self.loadConversationList()
                }
                .store(in: self.cancelBag)
        }
        
        func deleteConversation(at offsets: IndexSet) {
            
            guard let index = offsets.first?.codingKey.intValue else{
                return
            }
            
            do {
                let conversation = try self.conversations.value?.element(at: index)
                self.container.services.conversationService.deleteConversation(conversationID: conversation!.id)
                    .sink { error in
#warning("Handel error")
                        print("error: \(error)")
                    } receiveValue: { [weak self] in
                        //                    self!.conversationList.remove(at: index)
                        self!.loadConversationList()
                    }
                    .store(in: self.cancelBag)
            }catch {
                print("Error while getting conversation")
            }
            // conversationList[index]
            
        }
        
        func loadMore() {
            guard let convos = conversations.value else {
                return
            }
            
//            listIndex += 1
//            if listIndex >= convos.count { return }
//            conversationList.append(convos[self.listIndex])
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListView(viewModel: ConversationListView.ViewModel(coninater: .preview))
    }
}
