//
//  TropicanaViewController.swift
//  Tropicana
//
//  Created by Prashant Prajapati on 05/02/18.
//  Copyright © 2018 Prashant Prajapati. All rights reserved.
//

import UIKit

class TropicanaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var images = [UIImage(named: "Grape"), UIImage(named: "Watermelon"), UIImage(named: "Mango"), UIImage(named: "Strawberry"), UIImage(named: "Kiwi"), UIImage(named: "Lemon"), UIImage(named: "Apple"), UIImage(named: "Pear"), UIImage(named: "Cherry"), UIImage(named: "Orange"), UIImage(named: "Banana"), UIImage(named: "Mangosteen"), UIImage(named: "jackpot_icon")]
    
    let faces = [("Grape", 0.08), ("Watermelon", 0.08), ("Mango", 0.08), ("Strawberry", 0.08), ("Kiwi", 0.08), ("Lemon", 0.08), ("Apple", 0.08), ("Pear", 0.08), ("Cherry", 0.08), ("Orange", 0.08), ("Banana", 0.08), ("Mangosteen", 0.08), ("jackpot_icon", 0.04)]
    
    //odds for combinations : 3 of the same| 2 of the same| ANY of the 3
    let odds = [0.1, 0.25, 0.65]
    
    //Maximum Number for RNG bounds, default arc4random is 2^32
    let maxRandomRange = 4294967296
    
    //game numbers
    var startingMoney = 1000 // starting money
    var jackpot = 100000 // starting jackpot
    var betM = 0 //bet
    
    //labels outlets
    @IBOutlet weak var jackPot: UILabel!
    @IBOutlet weak var wallet: UILabel!
    @IBOutlet weak var bet: UILabel!
    
    //buttons outlets
    @IBOutlet weak var btnSpin: UIButton!
    @IBOutlet weak var btnBet: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var btnAddCash: UIButton!
    
    //pickers outlets
    @IBOutlet weak var row1: UIPickerView!
    @IBOutlet weak var row2: UIPickerView!
    @IBOutlet weak var row3: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        row1.selectRow(4, inComponent:0, animated:true)
        row2.selectRow(4, inComponent:0, animated:true)
        row3.selectRow(4, inComponent:0, animated:true)
        startingMoney = 0
        
        updateUI()
        
    }
    
    //checking that the bet is not bigger than wallet amount, then spinning the rows
    @IBAction func spin(_ sender: UIButton) {
        //generate random reel combination out of 3 of the same| 2 of the same| ANY of the 3
        let selectedCombination = randomSelection()
        
        //Fruit Face Indexies for purpose of tracking non repating elements
        var indexes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        
        switch selectedCombination {
        case 0: // 3 of the same
            let fruitIndex = getRandomFruitFaceIndex()
            row1.selectRow(fruitIndex, inComponent: 0, animated: true)
            row2.selectRow(fruitIndex, inComponent: 0, animated: true)
            row3.selectRow(fruitIndex, inComponent: 0, animated: true)
            
            //check if player won the jackpot
            if fruitIndex == 12 {
                startingMoney += jackpot
                jackpot = 10000
            }
            else {
                startingMoney += betM * 10
            }
        case 1: // 2 of the same
            
            //generation position where on the reel 2 of the same fruit should go
            let position = Int(arc4random_uniform(3))
            var fruitIndex = getRandomFruitFaceIndex()
            switch position {
            case 0: //Position: FRUIT FRUIT ANY
                row1.selectRow(fruitIndex, inComponent: 0, animated: true)
                row2.selectRow(fruitIndex, inComponent: 0, animated: true)
                
                indexes.remove(at: indexes.index(of: fruitIndex)!)
                
                fruitIndex = getRandomNonRepeatingFruitFaceIndex(indexies: indexes)
                row3.selectRow(fruitIndex, inComponent: 0, animated: true)
            case 1: //Position FRUIT ANY FRUIT
                row1.selectRow(fruitIndex, inComponent: 0, animated: true)
                row3.selectRow(fruitIndex, inComponent: 0, animated: true)
                
                indexes.remove(at: indexes.index(of: fruitIndex)!)
                
                fruitIndex = getRandomNonRepeatingFruitFaceIndex(indexies: indexes)
                row2.selectRow(fruitIndex, inComponent: 0, animated: true)
            case 2: //Position ANY FRUIT FRUIT
                row2.selectRow(fruitIndex, inComponent: 0, animated: true)
                row3.selectRow(fruitIndex, inComponent: 0, animated: true)
                
                indexes.remove(at: indexes.index(of: fruitIndex)!)
                
                fruitIndex = getRandomNonRepeatingFruitFaceIndex(indexies: indexes)
                row1.selectRow(fruitIndex, inComponent: 0, animated: true)
            default: break
            }
            
            //player's winnings
            startingMoney += betM
        case 2: // 3 of Any
            
            //reel 1
            var fruitIndex = getRandomFruitFaceIndex()
            row1.selectRow(fruitIndex, inComponent: 0, animated: true)
            indexes.remove(at: indexes.index(of: fruitIndex)!)
            //reel 2
            fruitIndex = getRandomNonRepeatingFruitFaceIndex(indexies: indexes)
            row2.selectRow(fruitIndex, inComponent: 0, animated: true)
            indexes.remove(at: indexes.index(of: fruitIndex)!)
            //reel 3
            fruitIndex = getRandomNonRepeatingFruitFaceIndex(indexies: indexes)
            row3.selectRow(fruitIndex, inComponent: 0, animated: true)
            
            //Increse jackpot if player loses
            jackpot += betM * 2
            
        default:
            break
        }
        
        //update UI to reflect current game state
        updateUI()
    }
    
    //increasing basic bet (5$) with step in 5$. Example: 5->10->15...
    @IBAction func bet(_ sender: UIButton) {
//        if (startingMoney >= 5 )  {
            betM = 5
            startingMoney = 5
            btnSpin.isEnabled = true
            btnBet.isEnabled = true //startingMoney < 5 ? false : true
//        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    @IBAction func bet5(_ sender: UIButton) {
//        if (startingMoney >= 5 )  {
            betM = 5
            startingMoney = 5
            btnSpin.isEnabled = true
            btnBet.isEnabled = true //startingMoney < 5 ? false : true
//        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    @IBAction func bet10(_ sender: UIButton) {
//        if (startingMoney >= 5 )  {
            betM = 10
            startingMoney = 10
            btnSpin.isEnabled = true
            btnBet.isEnabled = true //< 5 ? false : true
//        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    @IBAction func bet20(_ sender: UIButton) {
        //        if (startingMoney >= 5 )  {
        betM = 20
        startingMoney = 20
        btnSpin.isEnabled = true
        btnBet.isEnabled = true //< 5 ? false : true
        //        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    @IBAction func bet25(_ sender: UIButton) {
        //        if (startingMoney >= 5 )  {
        betM = 25
        startingMoney = 25
        btnSpin.isEnabled = true
        btnBet.isEnabled = true //startingMoney < 5 ? false : true
        //        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    @IBAction func bet50(_ sender: UIButton) {
        //        if (startingMoney >= 5 )  {
        betM = 50
        startingMoney = 50
        btnSpin.isEnabled = true
        btnBet.isEnabled = true //startingMoney < 5 ? false : true
        //        }
        wallet.text = String (startingMoney)
        bet.text = String (betM)
    }
    
    //reseting user's wallet to starting amount (500$)
    @IBAction func reset(_ sender: UIButton) {
        startingMoney = 0
        jackpot = 100000
        updateUI()
    }
    
    //putting app to the background
    @IBAction func quit(_ sender: UIButton) {
        //suspending application to background
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
    }
    
    //adding cash to the user wallet
    @IBAction func addCash(_ sender: UIButton) {
        startingMoney += 1000
        btnBet.isEnabled = true
        wallet.text = String (startingMoney)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return images.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return UIImageView(image: images[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return ((images[0]?.size.height)! + 15)
    }
    
    //________ CUTSOM FUNC SEC ______
    //Update UI Labels and Reset Bet
    func updateUI() {
        jackPot.text = String (jackpot)
        wallet.text = String (startingMoney)
        betM = 0
        bet.text = String (betM)
        btnSpin.isEnabled = false
        btnBet.isEnabled = true //startingMoney < 5 ? false : true
    }
    
    //get RandomNumber
    func getRandomNumber() -> Int {
        let randomNumber = arc4random()
        
        return Int(randomNumber)
    }
    
    //Randomly select combination for the reel using given odds
    func randomSelection() -> Int{
        let randomNumber = getRandomNumber()
        var cWeight:Double  = 0
        
        for (i, odd) in odds.enumerated() {
            cWeight += odd
            if ( randomNumber < Int(cWeight * Double(maxRandomRange)) ) {
                return i
            }
        }
        
        return -1
    }
    
    //Randomly select fruit face index using given odds
    func getRandomFruitFaceIndex() -> Int {
        let randomNumber = getRandomNumber()
        var cWeight:Double = 0
        
        for (i, element) in faces.enumerated() {
            cWeight += element.1
            if (randomNumber < Int(cWeight * Double(maxRandomRange))) {
                return i
            }
        }
        
        return -1
    }
    
    //Generate Non Reapitng Fruit Faces Index from avaliable collection of indexes
    func getRandomNonRepeatingFruitFaceIndex(indexies: [Int]) -> Int {
        var randomIndex = -1
        
        repeat {
            randomIndex = getRandomFruitFaceIndex()
        } while (!indexies.contains(randomIndex))
        
        return randomIndex
    }
    
}
