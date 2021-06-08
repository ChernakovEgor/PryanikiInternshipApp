//
//  Model.swift
//  PryanikiInternshipApp
//
//  Created by Egor Chernakov on 07.06.2021.
//

import Foundation

//MARK: – Main model classes
struct Model {
    let textLabel: TextLabel?
    let picture: PictureView?
    var selector: SelectorView?
    var viewOrder: Observable<[String]>
}

struct TextLabel {
    let name: String
    let text: String
}

struct SelectorView {
    let name: String
    var selectedID: Observable<Int>
    let variants: [Variant]
}

struct PictureView {
    let name: String
    let text: String
    let url: String
}

//MARK: - Class used for creating two-way bindings.
class Observable<ObservedType> {
    private var _value: ObservedType
    
    //is called to send the current value to the watching object
    var valueChanged: ((ObservedType) -> ())?
    
    var value: ObservedType {
        get {
            return _value
        }
        set {
            _value = newValue
            valueChanged?(_value)
        }
    }
    
    init(_ value: ObservedType) {
        _value = value
    }
    
    //is called when the other side of binding has changed
    func bindingChanged(to newValue: ObservedType) {
        _value = newValue
        print("Value changed to \(newValue).")
    }
}


// MARK: - Structs used to parse JSON data
struct FetchData: Codable {
    let data: [ViewData]
    let view: [String]
}

struct ViewData: Codable {
    let name: String
    let data: Contents
}

struct Contents: Codable {
    let text: String?
    let url: String?
    let selectedID: Int?
    let variants: [Variant]?

    enum CodingKeys: String, CodingKey {
        case text, url
        case selectedID = "selectedId"
        case variants
    }
}

struct Variant: Codable {
    let id: Int
    let text: String
}
