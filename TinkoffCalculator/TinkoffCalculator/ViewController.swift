//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by ilya Sergeev on 15.02.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
    case multiplyedByZero
}

enum Operation: String {
    case add = "+"
    case substruct = "-"
    case multiply = "X"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substruct:
            return number1 - number2
        case .multiply:
            if number2 == 0 {
                throw CalculationError.multiplyedByZero
            }
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}


class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }
    @IBAction func operatioButtonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text,
              let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        
        resetLabelText()
    }
    @IBAction func calculateButtonPressed() {
        guard let labelText = label.text,
              let labelNumber = numberFormatter.number(from: labelText)?.doubleValue else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            
            calculations.append((calculationHistory, result))
        } catch {
            label.text = "Error"
        }
        
        calculationHistory.removeAll()
    }
    
    var currentLabel = false
    var calculationHistory: [CalculationHistoryItem] = []
    
    var calculations: [(expression: [CalculationHistoryItem], result: Double)] = []
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetLabelText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        
        
        if let vc = calculationsListVC as? CalculationsListViewController {
            if label.text != nil {
                vc.calculattions = calculations
            } else {
                
            }
            
            
            navigationController?.pushViewController(calculationsListVC, animated: true)
        }
        
    }
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1] else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        return currentResult
    }
    
    func resetLabelText() {
//        label.text = "0"
        
        let tagButton = label.text
        let cancel = "C"
        
        if currentLabel == true {
            label.text = tagButton
        }
        if  label.text == cancel {
            currentLabel = false
            label.text = ""
        } else {
            label.text = ""
        }
    }
}
