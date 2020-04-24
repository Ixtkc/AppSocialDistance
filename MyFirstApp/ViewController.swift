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
    var array_master: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        outputLabel.text = String(array_master.count)
    }

    @IBOutlet weak var outputLabel: UILabel!
    @IBAction func shuffleButton(_ sender: Any) {
        // CoreBluetoothを初期化および始動.
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    /// PheripheralのScanが成功したら呼び出される。
    ///
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {

        let array_tmp = [String(describing: peripheral.name)]
        array_master = array_master.addUnique(array_tmp)
    }
}


