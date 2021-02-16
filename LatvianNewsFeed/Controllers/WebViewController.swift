//
//  WebViewController.swift
//  LatvianNewsFeed
//
//  Created by Elīna Zekunde on 13/02/2021.
//

import UIKit
import WebKit
import CoreData

class WebViewController: UIViewController, WKNavigationDelegate {

    var newsList = [News]()
    var context: NSManagedObjectContext?
    var urlString = String()
    var titleString = String()
    var newsImage: UIImage?
    
    @IBOutlet var webView: WKWebView!
    
    @IBAction func saveItemTapped(_ sender: Any) {
        let newItem = News(context: self.context!)
        newItem.title = titleString
        newItem.url = urlString
        
        guard let imageData: Data = (newsImage?.pngData()) else { return }
        
        if !imageData.isEmpty {
            newItem.image = imageData
        }
        
        self.newsList.append(newItem)
        saveData()
        
        warningPopup(withTitle: "Saved!", withMessage: nil)
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebKit"
        
        guard let url = URL(string: urlString) else { return }
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func warningPopup(withTitle title: String?, withMessage message: String?) {
        DispatchQueue.main.async {
            let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            popup.addAction(okButton)
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    func saveData() {
        do {
            try context?.save()
        } catch {
            warningPopup(withTitle: "Error!", withMessage: error.localizedDescription)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start navigation")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("End navigation")
    }
}
