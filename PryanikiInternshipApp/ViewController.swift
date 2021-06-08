//
//  ViewController.swift
//  PryanikiInternshipApp
//
//  Created by Egor Chernakov on 07.06.2021.
//

import UIKit

//MARK: - ViewController
class ViewController: UIViewController {
    
    var stackView: UIStackView!
    
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStackView()
        arrangeViews()
        
        viewModel.getOrder()?.valueChanged = { [weak self] _ in
            self?.arrangeViews()
        }
        
        title = "Simulate model change:"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle)),
            UIBarButtonItem(title: "3", style: .plain, target: self, action: #selector(reset(_:))),
            UIBarButtonItem(title: "2", style: .plain, target: self, action: #selector(reset(_:))),
            UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(reset(_:))),
            ]
    }
    
    //used to simulate internal change of the model
    @objc func reset(_ sender: UIBarButtonItem) {
        let number = Int(sender.title!)!
        viewModel.changeSelectedID(to: number)
    }
    
    @objc func shuffle() {
        viewModel.shuffleOrder()
    }
    
    //arranges views according to giben order
    func arrangeViews() {
        guard let order = viewModel.getOrder() else { return }
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for viewName in order.value {
            switch viewName {
            case "hz":
                if let label = createTextLabel() {
                    stackView.addArrangedSubview(label)
                }
            case "picture":
                if let picture = createPictureView() {
                    stackView.addArrangedSubview(picture)
                }
            case "selector":
                if let selector = createSelector() {
                    stackView.addArrangedSubview(selector)
                }
            default:
                return
            }
        }
        
        for view in stackView.arrangedSubviews {
            view.layer.cornerRadius = 10
            view.layer.backgroundColor = UIColor.systemGray6.cgColor
        }
    }
    
    //configures main stackView
    func configureStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    //creates the instance of the ImageView using parsed data
    func createPictureView() -> UIView? {
        guard let pictureData = viewModel.getPictureData() else { return nil }
        
        let stackView = UIStackView()
        let imageView = UIImageView()
        let label = UILabel()
        
        DispatchQueue.global().async {
            if let url = URL(string: pictureData.url) {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                            imageView.contentMode = .scaleAspectFit
                        }
                    }
                }
            }
        }
        
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        label.text = pictureData.text
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        stackView.axis = .vertical
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        stackView.isUserInteractionEnabled = true
        stackView.addGestureRecognizer(tapRecognizer)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        stackView.accessibilityIdentifier = pictureData.name
        
        return stackView
    }
    
    //creates the instance of UILabel using parsed data
    func createTextLabel() -> UILabel? {
        guard let labelData = viewModel.getLabelData() else { return nil }
        
        let label = UILabel()
        label.accessibilityIdentifier = labelData.name
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        label.text = "  \(labelData.text)   "
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapRecognizer)
        
        return label
    }
    
    //creates the instance of the BoundPicker using parsed data
    func createSelector() -> BoundPicker? {
        guard let selectorData = viewModel.getSelectorData() else { return nil }
        
        let picker = BoundPicker()
        picker.layer.shadowColor = UIColor.black.cgColor
        picker.bind(to: selectorData.selectedID)
        picker.delegate = self
        picker.selectRow(selectorData.selectedID.value - 1, inComponent: 0, animated: true)
        
        return picker
    }
    
    //shows UIAlertController with the info of the view tapped
    @objc func tap(_ sender: UIGestureRecognizer) {
        if let name = sender.view?.accessibilityIdentifier {
            let ac = UIAlertController(title: "You tapped on the \(name).", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

//MARK: - UIPickerViewDelegate & DataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getSelectorData()!.variants.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let boundPicker = pickerView as? BoundPicker
        boundPicker?.valueChanged()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let selectorData = viewModel.getSelectorData() else { return "" }
        let id = selectorData.variants[row].id
        let text = selectorData.variants[row].text
        return "\(id). \(text)"
    }
}

//MARK: - Custom UIPickerView subclass
//for creating two-way binding with selectedID property
class BoundPicker: UIPickerView {
    private var changedClosure: (()->())?
    
    func valueChanged() {
        changedClosure?()
    }
    
    //used to bind the UI object to the observable object
    func bind(to observable: Observable<Int>) {
        changedClosure = { [weak self] in
            observable.bindingChanged(to: (self?.selectedRow(inComponent: 0) ?? 0) + 1)
        }
        
        observable.valueChanged = { [weak self] newValue in
            self?.selectRow(newValue - 1, inComponent: 0, animated: true)
        }
    }
}

