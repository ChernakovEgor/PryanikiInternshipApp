//
//  ViewModel.swift
//  PryanikiInternshipApp
//
//  Created by Egor Chernakov on 07.06.2021.
//

import Foundation

//MARK: - ViewModel class
//Used for fetching & parsing data and providing it to ViewController
class ViewModel {
    
    private static let urlString = "https://pryaniky.com/static/json/sample.json"
    
    private var model: Model?
    
    init() {
        guard let data = fetch() else { return }
        guard let parsedData = parse(json: data) else { return }
        
        createModel(from: parsedData)
    }
    
    //fetching data from urlString
    private func fetch() -> Data? {
        if let url = URL(string: ViewModel.urlString) {
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return nil
    }
    
    //decoding fetched data
    private func parse(json: Data) -> FetchData? {
        let decoder = JSONDecoder()
        
        if let decoded = try? decoder.decode(FetchData.self, from: json) {
            return decoded
        } else {
            print("Error: cound not parse data.")
        }
        
        return nil
    }
    
    //creating instance of main model & saving data
    private func createModel(from parsedData: FetchData) {
        var textLabel: TextLabel?
        if let textLabelData = parsedData.data.first(where: {$0.name == "hz"}) {
            textLabel = TextLabel(name: textLabelData.name, text: textLabelData.data.text!)
        }
        
        var picture: PictureView?
        if let pictureData = parsedData.data.first(where: {$0.name == "picture"}) {
            picture = PictureView(name: pictureData.name, text: pictureData.data.text!, url: pictureData.data.url!)
        }
        
        var selector: SelectorView?
        if let selectorData = parsedData.data.first(where: {$0.name == "selector"}) {
            selector = SelectorView(name: selectorData.name, selectedID: Observable(selectorData.data.selectedID!), variants: selectorData.data.variants!)
        }
        
        model = Model(textLabel: textLabel, picture: picture, selector: selector, viewOrder: Observable(parsedData.view))
    }
    
    func getPictureData() -> PictureView? {
        return model?.picture
    }
    
    func getLabelData() -> TextLabel? {
        return model?.textLabel
    }
    
    func getSelectorData() -> SelectorView? {
        return model?.selector
    }
    
    func getOrder() -> Observable<[String]>? {
        return model?.viewOrder
    }
    
    func changeSelectedID(to number: Int) {
        model?.selector?.selectedID.value = number
    }
    
    func shuffleOrder() {
        model?.viewOrder.value = (model?.viewOrder.value.shuffled())!
    }
}
