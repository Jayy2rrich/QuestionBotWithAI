//
//  ViewController.swift
//  QuestionBotWithAI
//
//  Created by 7g on 4/21/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    
    let apiKey = "AIzaSyBAOwmf3YZhqODFCbA_VrFVW1mu60onnFI"
        let searchEngineID = "76af6595beb5045b0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func askButtonTapped(_ sender: Any) {
        guard let question = questionTextField.text, !question.isEmpty else {
                    answerLabel.text = "Please enter a question."
                    return
                }
                
                searchGoogle(for: question)
            }
    
    func searchGoogle(for query: String) {
        let urlString = "https://www.googleapis.com/customsearch/v1"
        let parameters: [String: Any] = [
            "key": apiKey,
            "cx": searchEngineID,
            "q": query
        ]
        
        AF.request(urlString, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                if let jsonData = data as? [String: Any],
                   let items = jsonData["items"] as? [[String: Any]],
                   let firstItem = items.first,
                   let snippet = firstItem["snippet"] as? String {
                    let refinedSnippet = self.refineAnswer(snippet)
                    DispatchQueue.main.async {
                        self.answerLabel.text = refinedSnippet
                    }
                } else {
                    DispatchQueue.main.async {
                        self.answerLabel.text = "No results found."
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.answerLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    func refineAnswer(_ text: String) -> String {
        let sentences = text.split { $0 == "." }
        let maxSentences = 3
        let limitedSentences = sentences.prefix(maxSentences).joined(separator: ". ")
        return String(limitedSentences)
    }

}

