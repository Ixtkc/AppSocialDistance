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

import Charts

extension Array where Element: Hashable {
    func addUnique(_ array: Array) -> Array {
        let dict = Dictionary(map{ ($0, 1) }, uniquingKeysWith: +)
        return self + array.filter{ dict[$0] == nil }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet var chartView: BarChartView!
    
    var peripherals = [UUID : CBPeripheral]()
    var centralManager: CBCentralManager!
    var deviceArray: [String] = [] // 接触したデバイス名を保存
    
    var timer: Timer!
    let dateFormater = DateFormatter()
    var todayDate: String!
    var weekCounts: [Int] = [0, 0, 0, 0, 0, 0, 0] // 1週間の記録
    
    var alertController: UIAlertController!

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
        
        // dateformatterのsetting
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        
        // 今日の日付を取得
        // userdefaultのキーに使う
        todayDate = dateFormater.string(from: Date())
        
        // userdefaultから値を取得
        if UserDefaults.standard.object(forKey: todayDate) != nil {
            deviceArray = UserDefaults.standard.object(forKey: todayDate) as! [String]
        }
        
        // 1週間の記録を取得
        self.weekCounts = getWeekData(dateFormater: self.dateFormater)
        
        // 検出数を表示
        outputLabel.text = String(deviceArray.count)
        
        // グラフを表示
        graphSetup(barChartView: chartView, rawData: weekCounts.reversed())
        
        // 10秒ごとに検出
        createTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // UserDefaults.standard.set(true, forKey: "firstLaunch")
        // 初回起動時の処理
        if (UserDefaults.standard.bool(forKey: "firstLaunch")) {
            openModal()
            UserDefaults.standard.set(false, forKey: "firstLaunch")
        }
        
    }
    
    func openModal() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let modal: ModalViewController = storyBoard.instantiateViewController(withIdentifier: "modal") as! ModalViewController
        modal.modalPresentationStyle = .overFullScreen
        modal.modalTransitionStyle = .crossDissolve

        self.present(modal, animated: false, completion: nil)
    }
    
    func graphSetup(barChartView: BarChartView, rawData: [Int]) {
        let entries = rawData.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }
        let dataSet = BarChartDataSet(entries: entries)
        let data = BarChartData(dataSet: dataSet)
        
        // X軸のラベルを設定
        barChartView.xAxis.valueFormatter = BarChartFormatter()
        // X軸のラベルの位置を下に設定
        barChartView.xAxis.labelPosition = .bottom
        // X軸のラベルの色を設定
        barChartView.xAxis.labelTextColor = .systemGray
        // X軸の線、グリッドを非表示にする
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        
        // 右側のY座標軸は非表示にする
        barChartView.rightAxis.enabled = false
        // Y座標の値が0始まりになるように設定
        barChartView.leftAxis.axisMinimum = 0.0
        barChartView.leftAxis.drawZeroLineEnabled = true
        barChartView.leftAxis.zeroLineColor = .systemGray
        // ラベルの数を設定
        barChartView.leftAxis.labelCount = 5
        // ラベルの色を設定
        barChartView.leftAxis.labelTextColor = .systemGray
        // グリッドの色を設定
        barChartView.leftAxis.gridColor = .systemGray
        // 軸線は非表示にする
        barChartView.leftAxis.drawAxisLineEnabled = false
        
        // 凡例を非表示
        barChartView.legend.enabled = false
        
        // 平均の線を表示 let avg = rawData.reduce(0) { return $0 + $1 } / rawData.count
//        let avg = rawData.reduce(0) { return $0 + $1 } / rawData.count
//        let limitLine = ChartLimitLine(limit: Double(avg))
//        limitLine.lineColor = .systemOrange
//        limitLine.lineDashLengths = [4]
//        barChartView.leftAxis.addLimitLine(limitLine)
        
        barChartView.data = data
    }
    
    func getWeekData(dateFormater: DateFormatter) -> [Int] {
        var weekCounts: [Int] = [0, 0, 0, 0, 0, 0, 0]
        
        for i in 0...6 {
            let today = Date()
            let dayBeforeDate = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            let dayBeforeStr = dateFormater.string(from: dayBeforeDate)
            
            if UserDefaults.standard.object(forKey: dayBeforeStr) != nil {
                let array = UserDefaults.standard.object(forKey: dayBeforeStr) as! [String]
                weekCounts[i] = array.count
            } else {
                weekCounts[i] = 0
            }
        }
        
        return weekCounts
    }
    
    // 1秒ごとに周辺のデバイスを検出
    func createTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectDevices(timer:)), userInfo: nil, repeats: true)
    }
    
    // デバイスを検出
    @objc func detectDevices(timer: Timer) {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    @IBAction func updateGraphBtn() {
        let weekCounts = getWeekData(dateFormater: self.dateFormater)
        self.weekCounts = weekCounts
        graphSetup(barChartView: self.chartView, rawData: weekCounts.reversed())
    }
}

public class BarChartFormatter: NSObject, IAxisValueFormatter{
    let labels = ["6日前", "5日前", "4日前", "3日前", "2日前", "昨日", "今日"]
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
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
        let array_tmp = [String(describing: peripheral.name)]
        // let array_tmp = [String(describing: peripheral.identifier.uuid)] // デバイス名のない機器を検出
        
        deviceArray = deviceArray.addUnique(array_tmp)
        outputLabel.text = String(deviceArray.count)
        
        // userdefaults に保存
        UserDefaults.standard.set(deviceArray, forKey: todayDate)
    }
}


