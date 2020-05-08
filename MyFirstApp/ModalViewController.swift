//
//  ModalViewController.swift
//  MyFirstApp
//
//  Created by 梶原大進 on 2020/05/07.
//  Copyright © 2020 Takashi Nakano. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    @IBOutlet var closeBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //角丸設定
        self.closeBtn.layer.cornerRadius = 12
        self.closeBtn.clipsToBounds = true
        
        //影の設定
        self.closeBtn.layer.shadowOpacity = 0.4
        self.closeBtn.layer.shadowRadius = 12
        self.closeBtn.layer.shadowColor = UIColor.black.cgColor
        self.closeBtn.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    // 閉じるボタンがタップされた時
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

    // ポップアップの外側をタップした時にポップアップを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        var tapLocation: CGPoint = CGPoint()
        // タッチイベントを取得する
        let touch = touches.first
        // タップした座標を取得する
        tapLocation = touch!.location(in: self.view)

        let popUpView: UIView = self.view.viewWithTag(100)! as UIView

        if !popUpView.frame.contains(tapLocation) {
            self.dismiss(animated: false, completion: nil)
        }
    }

}
