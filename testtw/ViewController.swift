//
//  ViewController.swift
//  testtw
//
//  Created by 武内駿 on 2016/09/15.
//  Copyright © 2016年 Syun Takeuchi. All rights reserved.
//

//とりあえずソーシャルframeworkを使ってみる
//ツイッターにアクセスしてタイムライン情報を受け取るまで

import UIKit
import Accounts
import Social

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //アカウント取得
        getAccounts(){(account: [ACAccount]) -> Void in
            //今回はとりあえず頭のアカウントを設定
            //アカウント振り分け処理は追って実装（自分しか使わないし要らない？）
            self.twitterAccount=account[0]
            //タイムライン取得
            //これもとりあえず仮置き
            self.getTimeline(){(timeLine: NSMutableArray) -> Void in
                //とりあえず書き出し
                print(timeLine)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ツイッターアカウント変数
    var accountstore = ACAccountStore()
    var  twitterAccount : ACAccount?
    
    //ツイッターアカウント取得
    func getAccounts(callback: [ACAccount] -> Void) {
        //アカウントタイプ設定
        let accountType:ACAccountType = accountstore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        //本体のツイッターアカウント情報を問い合わせる
        //複数ある場合を想定して配列で返す
        accountstore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError?) -> Void in
            if error != nil {
                //何かしらのエラー
                print("error! \(error)")
                return
            }
            if !granted {
                //アカウント利用不許可
                print("error! Twitterアカウントの利用が許可されていません")
                return
            }
            //利用許可で配列に収納
            let accounts = self.accountstore.accountsWithAccountType(accountType) as! [ACAccount]
            //配列が空っぽ＝アカウント登録なし
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            print("アカウント取得完了")
            //アカウント配列を返す
            callback(accounts)
        }
    }
    
    //リクエスト作成
    func sendRequest(url: NSURL, requestMethod: SLRequestMethod, params: AnyObject?, responseHandler: (responseData: NSData!, urlResponse: NSHTTPURLResponse!) -> Void) {
        let request:SLRequest = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: requestMethod,
            URL: url,
            parameters: params as? [NSObject : AnyObject]
        )
        //アカウント情報移植
        request.account = twitterAccount
        //リクエストを投げる
        request.performRequestWithHandler { (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
            if error != nil {
                print("error is \(error)")
            } else {
                responseHandler(responseData: responseData, urlResponse: urlResponse)
            }
        }
    }
    
    //タイムライン取得
    func getTimeline(callbabk: NSMutableArray -> Void) {
        //リクエストの宛先（今回はtwitter
        let url:NSURL = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")!
        //リクエスト実行
        sendRequest(url, requestMethod: .GET, params: nil) { (responseData, urlResponse) -> Void in
            do {
                let result:NSMutableArray = [try NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments).mutableCopy()]
                /*メモ
                 JSONから作成した配列をそのままキャストして引き渡すとエラーになる。
                 mutableに保存しても取り出し時にimmutableな配列になるらしい。
                 mutableCopyを一回噛ませること（そのうち修正されそう・・・）
                 */
                //無事処理完了でコールバックする
                callbabk(result)
            } catch {
                print("エラーが発生しました")
            }
        }
    }


}

