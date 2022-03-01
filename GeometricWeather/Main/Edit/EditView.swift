//
//  EditView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI
import GeometricWeatherBasic

struct EditView: View {
    
    @State var mainCardList: [MainCard]
    @State private var deletedList: [MainCard]
    
    init() {
        self.mainCardList = SettingsManager.shared.mainCards

        let mainCardSet = Set(SettingsManager.shared.mainCards)
        self.deletedList = MainCard.all.filter({ card in
            return !mainCardSet.contains(card)
        })
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(self.mainCardList) { card in
                    Text(
                        NSLocalizedString(card.key, comment: "")
                    ).font(
                        Font(titleFont)
                    ).padding(8.0)
                }.onDelete(
                    perform: self.onDelete(_:)
                ).onMove(
                    perform: self.onMove(from:to:)
                )
            }.listStyle(
                .plain
            ).environment(
                \.editMode, .constant(.active)
            )
            
            VStack {
                Spacer()
                
                Color(UIColor.separator).opacity(0.33).frame(height: 1)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: littleMargin) {
                        Spacer(minLength: littleMargin)
                        
                        ForEach(self.deletedList) { card in
                            MainCardTagView(
                                title: NSLocalizedString(
                                    card.key,
                                    comment: ""
                                )
                            ).onTapGesture {
                                self.onAdd(card)
                            }
                        }
                        
                        Spacer(minLength: littleMargin)
                    }.frame(
                        height: 56
                    )
                }.frame(
                    height: 56
                ).background(
                    Color(UIColor.systemBackground)
                )
            }.opacity(
                self.deletedList.isEmpty ? 0 : 1
            )
        }.onDisappear {
            if !SettingsManager.shared.mainCards.elementsEqual(self.mainCardList) {
                SettingsManager.shared.mainCards = self.mainCardList
            }
        }
    }
    
    private func onDelete(_ indexSet: IndexSet) {
        guard let index = Array(indexSet).first else {
            return
        }
        
        withAnimation {
            let card = self.mainCardList.remove(at: index)
            self.deletedList.append(card)
        }
    }
    
    private func onMove(from indexSet: IndexSet, to destination: Int) {
        withAnimation {
            self.mainCardList.move(fromOffsets: indexSet, toOffset: destination)
        }
    }
    
    private func onAdd(_ card: MainCard) {
        guard let index = self.deletedList.firstIndex(of: card) else {
            return
        }
        
        withAnimation {
            let card = self.deletedList.remove(at: index)
            self.mainCardList.append(card)
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
