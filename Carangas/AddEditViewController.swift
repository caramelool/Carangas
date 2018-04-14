//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    var car: Car!
    var pickerView: UIPickerView!
    var brands: [Brand]!
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (car != nil) {
            tfName.text = car.name
            tfBrand.text = car.brand
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar", for: .normal)
        }
        
        prepareBrands()
    }
    
    private func prepareBrands() {
        pickerView = UIPickerView() //Instanciando o UIPickerView
        pickerView.backgroundColor = .white
        pickerView.delegate = self  //Definindo seu delegate
        pickerView.dataSource = self  //Definindo seu dataSource
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        REST.loadBrands { (brands, error) in
            if error == nil  {
                self.brands = brands
                DispatchQueue.main.async {
                    self.tfBrand.inputView = self.pickerView
                    self.tfBrand.inputAccessoryView = toolbar
                    if let row = brands?.index(where: { $0.name == self.tfBrand.text! }) {
                        self.pickerView.selectRow(row, inComponent: 0, animated: false)
                    }
                }
            }
        }
    }
    
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].name
        cancel()
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        sender.isEnabled = false
        sender.alpha = 0.5
        sender.backgroundColor = .gray
        
        if (car == nil) {
            car = Car()
        }
        
        car.name = tfName.text!
        car.brand = tfBrand.text!
        car.price = Double(tfPrice.text!)!
        car.gasType = scGasType.selectedSegmentIndex
        
        loading.startAnimating()
        if (car._id == nil) {
            REST.saveCar(car, onComplete: onComplete)
        } else {
            REST.updateCar(car, onComplete: onComplete)
        }
    }

    private func onComplete(success: Bool) {
        DispatchQueue.main.async {
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.loading.stopAnimating()
                self.btAddEdit.isEnabled = true
                self.btAddEdit.alpha = 1.0
                self.btAddEdit.backgroundColor = UIColor(named: "main")
                let dialog = UIAlertController(title: "Erro", message: "Não foi possivel salvar o carro!", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    dialog.dismiss(animated: true, completion: nil)
                }))
                self.present(dialog, animated: true, completion: nil)
            }
        }
    }
}

extension AddEditViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Retornando o texto recuperado do objeto dataSource, baseado na linha selecionada
        return brands[row].name
    }
}

extension AddEditViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}
