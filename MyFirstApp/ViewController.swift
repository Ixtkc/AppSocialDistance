//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Takashi Nakano on 2020/04/21.
//  Copyright © 2020 Takashi Nakano. All rights reserved.
//
//  ボタンを押すと pheripheral の名前を取得し、配列に追加. その際の配列はユニークな値であるように保持.
//
//
//

import UIKit
import CoreBluetooth

extension Array where Element: Hashable {
    func addUnique(_ array: Array) -> Array {
        let dict = Dictionary(map{ ($0, 1) }, uniquingKeysWith: +)
        return self + array.filter{ dict[$0] == nil }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var outputLabel: UILabel!
    
    var peripherals = [UUID : CBPeripheral]()
    var centralManager: CBCentralManager!
    var deviceArray: [String] = [] // 接触したデバイス名を保存
    
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //角丸設定
        self.outputLabel.layer.cornerRadius = 12
        self.outputLabel.clipsToBounds = true
        
        //影の設定
        self.outputLabel.layer.shadowOpacity = 0.4
        self.outputLabel.layer.shadowRadius = 12
        self.outputLabel.layer.shadowColor = UIColor.black.cgColor
        self.outputLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        //色の設定
        _ = UIColor(red: 224/255.0, green: 98/255.0, blue: 106/255.0, alpha: 1.0)
        _ = UIColor(red: 242/255.0, green: 164/255.0, blue: 58/255.0, alpha: 1.0)
        _ = UIColor(red: 98/255.0, green: 186/255.0, blue: 224/255.0, alpha: 1.0)
        
        
        // userdefaultから値を取得
        if UserDefaults.standard.object(forKey: "deviceArray") != nil {
            deviceArray = UserDefaults.standard.object(forKey: "deviceArray") as! [String];
        }
        
        // 検出数を表示
        outputLabel.text = String(deviceArray.count)
        
        // 10秒ごとに検出
        createTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(true, forKey: "firstLaunch")
        // 初回起動時の処理
        if (UserDefaults.standard.bool(forKey: "firstLaunch")) {
            openModal()
            UserDefaults.standard.set(false, forKey: "firstLaunch")
        }
    }
    
    func openModal() {
        print("modal")
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let modal: ModalViewController = storyBoard.instantiateViewController(withIdentifier: "modal") as! ModalViewController
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve

        self.present(modal, animated: false, completion: nil)
    }
    
    // 1秒ごとに周辺のデバイスを検出
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectDevices(timer:)), userInfo: nil, repeats: true)
        print("createTimer")
    }
    
    // デバイスを検出
    @objc func detectDevices(timer: Timer) {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        print("detectiveDevice")
    }
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")

        switch central.state {
        case .poweredOff:
            print("Bluetoothの電源がOff")
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始.
            centralManager.scanForPeripherals(withServices: nil)
        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        @unknown default:
            print("?")
        }
    }

    /// PheripheralのScanが成功したら呼び出される。
    ///
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Called")
        let array_tmp = [String(describing: peripheral.name)]
        // let array_tmp = [String(describing: peripheral.identifier.uuid)] // デバイス名のない機器を検出
        
        deviceArray = deviceArray.addUnique(array_tmp)
        outputLabel.text = String(deviceArray.count)
        
        // userdefaults に保存
        UserDefaults.standard.set(deviceArray, forKey: "deviceArray")
    }
}


