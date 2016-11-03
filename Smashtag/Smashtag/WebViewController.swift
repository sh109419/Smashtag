//
//  WebViewController.swift
//  Smashtag
//
//  Created by hyf on 16/11/2.
//  Copyright © 2016年 hyf. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var urlString: String? {
        didSet {
            title = urlString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let url = NSURL(string: urlString!) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }

    func webViewDidStartLoad(webView: UIWebView) {
        spinner.startAnimating()
        print("start")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
        print("finish")
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        spinner.stopAnimating()
        print("err")
    }
    

}
