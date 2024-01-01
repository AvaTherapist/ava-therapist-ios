//
//  ConversationListView.swift
//  AITherapist
//
//  Created by Cyrus Refahi on 9/17/23.
//

import SwiftUI
import Combine

struct ConversationListView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    var body: some View {
        mainContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        CircleLoading()
    }
    
    private func loadingView() -> some View {
        CircleLoading()
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.viewModel.loadConversationListOnRetry()
        })
    }
}

// MARK: Displaying Content
private extension ConversationListView {
    func loadedView(_ conversationList: LazyList<Conversation>) -> some View {
        return NavigationStack {
            VStack(spacing: -40){
                ConversationCellHeader()
                    .frame(height: 60)
                    .zIndex(5)
                ZStack{
                    List{
                        ForEach (conversationList, id: \.id){ conversation in
                            ZStack{
                                ConversationCell(conversation: conversation)
                                    .frame(maxWidth: .infinity)
                                AvaNavigationLink {
                                    TherapyChatView(viewModel: .init(conversation: conversation, container: self.viewModel.container))
                                        .avaNavigationBarTopLeftButton(.back)
                                        .avaNavigationBarTitle("")
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .padding([.top, .bottom], 0)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .frame(maxHeight: .infinity)
                        }
                        .onDelete(perform: self.viewModel.deleteConversation)
                    }
                    .background(.clear)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .listStyle(.grouped)
                }
            }
        }
    }
}

extension ConversationListView{
    struct ConversationCellHeader: View {
        var body: some View {
            header
        }
        
        @ViewBuilder private var header: some View {
            HStack(alignment: .center, spacing: 10) {
                Text("Date")
                    .font(
                        Font.custom("Inter", size: 12)
                            .weight(.medium)
                    )
                    .foregroundColor(.black)
                    .frame(width: 77)
                
                Divider()
                Spacer()
                
                Text("Summary")
                    .font(
                        Font.custom("Inter", size: 12)
                            .weight(.medium)
                    )
                    .foregroundColor(.black)
                    .padding([.trailing], 30)
                
                Spacer()
                Divider()
                
                Text("Mood")
                    .font(
                        Font.custom("Inter", size: 12)
                            .weight(.medium)
                    )
                    .foregroundColor(.black)
                    .frame(width: 40)
            }
            .frame(height: 25)
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], 16)
        }
    }
    
    struct ConversationCell: View {
        var conversation: Conversation
        let imageName: String = "ImagePlaceholder"
        
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
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Text(getDateString())
                        .font(Font.custom("SF Pro Text", size: 11))
                        .kerning(0.066)
                        .multilineTextAlignment(.center)
                        .foregroundColor(ColorPallet.DarkBlue)
                    
                    ConversationCustomDivider()
                    
                    Text("We talked about.... dolor sit amet consectetur. Tempus dui vitae vivamus diam habitasse metus aliquet rhoncus. Potenti nulla pulvinar neque tellus lectus sit.vivamus diam habitasse metus aliquet rhonc Llorem ipsum dolor s")
                        .font(Font.custom("SF Pro Text", size: 11))
                        .kerning(0.066)
                        .foregroundColor(ColorPallet.DarkBlue)
                    
                    ConversationCustomDivider()
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 70, height: 70)
                        .background(
                            Image(self.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipped()
                        )
                        .cornerRadius(15)
                }
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .padding(16)
                
                Spacer()
                Rectangle()
                    .fill(ColorPallet.MediumTurquoiseBlue)
                    .frame(width: UIViewController().view.bounds.width, height: 1)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(10)
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

extension ConversationListView{
    struct ConversationCustomDivider: View {
        let color: Color = ColorPallet.DarkBlue
        let width: CGFloat = 1
        var body: some View {
            Rectangle()
                .fill(color)
                .frame(width: width)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

extension ConversationListView {
    class ViewModel: ObservableObject {
        let container: DIContainer
        let isRunningTests: Bool
        private var cancelBag = CancelBag()
        
        var conversations: Loadable<LazyList<Conversation>>{
            get{
                return self.container.appState[\.conversationData.conversations]
            }set{
                self.container.appState[\.conversationData.conversations] = newValue
            }
        }
        
        init(coninater: DIContainer, isRunningTests: Bool = ProcessInfo.processInfo.isRunningTests, conversations: Loadable<LazyList<Conversation>> = .notRequested) {
            self.container = coninater
            self.isRunningTests = isRunningTests
            
            container.appState.value.conversationData.objectWillChange.sink { value in
                self.objectWillChange.send()
            }
            .store(in: self.cancelBag)
            
            loadConversationList()
        }
        
        private func loadConversationList() {
            if (conversations == .notRequested) {
                self.container.services.conversationService.loadConversationList(conversations: self.loadableSubject(\.container.appState[\.conversationData.conversations]))
            }
        }
        
        func loadConversationListOnRetry(){
            loadConversationList()
        }
        
        func deleteConversation(at offsets: IndexSet) {
            guard let index = offsets.first?.codingKey.intValue else{
                return
            }
            
            guard let conversation = self.conversations.value?[index] else {
                return
            }
            
            self.container.services.conversationService.deleteConversation(conversationID: conversation.id)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.conversations = .loaded((self.conversations.value?.filter{ $0 != conversation}.lazyList)!)
                    default:
                        break
                    }
                }, receiveValue: {
                    
                })
                .store(in: self.cancelBag)
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListView(viewModel: ConversationListView.ViewModel(coninater: .preview))
    }
}
