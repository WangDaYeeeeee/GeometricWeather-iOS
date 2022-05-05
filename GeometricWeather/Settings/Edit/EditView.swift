//
//  EditView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class EditViewModel: ObservableObject {
    
    @Published var mainCardList: [MainCard] {
        didSet {
            self.isDefaultMainCardList.value = self.mainCardList.elementsEqual(MainCard.all)
        }
    }
    @Published var deletedList: [MainCard]
    
    let isDefaultMainCardList: EqualtableLiveData<Bool>
    
    init() {
        self.mainCardList = SettingsManager.shared.mainCards

        let mainCardSet = Set(SettingsManager.shared.mainCards)
        self.deletedList = MainCard.all.filter({ card in
            !mainCardSet.contains(card)
        })
        
        self.isDefaultMainCardList = EqualtableLiveData<Bool>(
            SettingsManager.shared.mainCards.elementsEqual(MainCard.all)
        )
    }
    
    func deleteMainCard(at index: Int) {
        withAnimation {
            let card = self.mainCardList.remove(at: index)
            self.deletedList.append(card)
        }
    }
    
    func moveMainCard(fromOffsets: IndexSet, toOffset: Int) {
        withAnimation {
            self.mainCardList.move(
                fromOffsets: fromOffsets,
                toOffset: toOffset
            )
        }
    }
    
    func addMainCard(withIndexOfDeletedList index: Int) {
        withAnimation {
            let card = self.deletedList.remove(at: index)
            self.mainCardList.append(card)
        }
    }
    
    func resetToDefault() {
        withAnimation {
            self.mainCardList = MainCard.all
            self.deletedList = [MainCard]()
        }
    }
}

struct EditView: View {
    
    @ObservedObject var model: EditViewModel
    
    var body: some View {
        ZStack {
            List {
                ForEach(self.model.mainCardList) { card in
                    Text(
                        getLocalizedText(card.key)
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
                        
                        ForEach(self.model.deletedList) { card in
                            MainCardTagView(
                                title: getLocalizedText(card.key)
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
                self.model.deletedList.isEmpty ? 0 : 1
            )
        }.onDisappear {
            if !SettingsManager.shared.mainCards.elementsEqual(
                self.model.mainCardList
            ) {
                SettingsManager.shared.mainCards = self.model.mainCardList
            }
        }
    }
    
    private func onDelete(_ indexSet: IndexSet) {
        guard let index = Array(indexSet).first else {
            return
        }
        
        self.model.deleteMainCard(at: index)
    }
    
    private func onMove(from indexSet: IndexSet, to destination: Int) {
        self.model.moveMainCard(fromOffsets: indexSet, toOffset: destination)
    }
    
    private func onAdd(_ card: MainCard) {
        guard let index = self.model.deletedList.firstIndex(of: card) else {
            return
        }
        
        self.model.addMainCard(withIndexOfDeletedList: index)
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(model: EditViewModel())
    }
}
