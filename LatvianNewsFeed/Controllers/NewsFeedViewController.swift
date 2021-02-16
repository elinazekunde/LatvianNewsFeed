//
//  ViewController.swift
//  LatvianNewsFeed
//
//  Created by Elīna Zekunde on 13/02/2021.
//

import UIKit
import Gloss

class NewsFeedViewController: UIViewController {

    var items: [Item] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.style = .large
        tableView.isHidden = true
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        handleRefreshTapped()
        activityIndicator(animated: true)
    }
    
    func activityIndicator(animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                self.tableView.isHidden = false
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func handleRefreshTapped() {
        let jsonUrl = "http://newsapi.org/v2/top-headlines?country=lv&category=business&apiKey=f5a3a8fb464541319c3a85b51cb401d8"
        
        guard let url = URL(string: jsonUrl) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                print("error:", err.localizedDescription)
            }
            
            guard let data = data else {
                print("Data error!")
                return
            }
            
            do {
                if let dictData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("dictData:", dictData)
                    self.populateData(dictData)
                }
            } catch {
                print("Error when converting JSON!")
            }
        }
        task.resume()
    }
    
    func populateData(_ dict: [String: Any]) {
        guard let responseDict = dict["articles"] as? [Gloss.JSON] else {
            return
        }
        
        items = [Item].from(jsonArray: responseDict) ?? []
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator(animated: false)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webView" {
            // Get the new view controller using segue.destination.
            if let vc = segue.destination as? WebViewController, let row = tableView.indexPathForSelectedRow?.row {
            // Pass the selected object to the new view controller.
                vc.urlString = items[row].url
                vc.titleString = items[row].title
                vc.newsImage = items[row].image
            }
        }
    }
}

extension NewsFeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsFeedCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        
        if let image = item.image {
            cell.newsImage.image = image
        }
        
        cell.titleLabel.text = item.title
        cell.setUI(with: item)
        
        return cell
    }
}
