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
    var peripherals = [UUID : CBPeripheral]()
    var centralManager: CBCentralManager!
    var deviceArray: [String] = [] // 接触したデバイス名を保存
//    let button = UIButton()
    
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // サイズ
//        button.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
//        button.backgroundColor = UIColor.darkGray
//        button.layer.masksToBounds = true
//        button.setTitle("Search", for: UIControl.State.normal)
//        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
//        button.layer.cornerRadius = 20.0
//        button.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height-50)
//        button.tag = 1
//        button.addTarget(self, action: #selector(onClickMyButton(sender:)), for: .touchUpInside)
//
//        // UIボタンをViewに追加.
//        self.view.addSubview(button);
        
        
        // userdefaultから値を取得
        if UserDefaults.standard.object(forKey: "deviceArray") != nil {
            deviceArray = UserDefaults.standard.object(forKey: "deviceArray") as! [String];
        }
        
        // 検出数を表示
        outputLabel.text = String(deviceArray.count)
        
        // 10秒ごとに検出
        createTimer()
    }

    @IBOutlet weak var outputLabel: UILabel!
    
    /// ボタンが押されたときに呼び出される。
//    @objc func onClickMyButton(sender: UIButton){
//        // CoreBluetoothを初期化および始動.
//        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
//    }
    
    // 10秒ごとに周辺のデバイスを検出
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.detectDevices(timer:)), userInfo: nil, repeats: true)
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


