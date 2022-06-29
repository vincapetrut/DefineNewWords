//
//  ViewController.swift
//  DefineNewWords
//
//  Created by Petruț Vinca on 28.06.2022.
//

import UIKit

class ViewController: UITableViewController {
    var startWords = [String]()
    var usedWords = [String]()
    var rootWord: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWord))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWord))
        
        let filePath = Bundle.main.url(forResource: "AvailableWords", withExtension: "txt")
        if let availableWords = try? String(contentsOf: filePath!) {
            startWords = availableWords.components(separatedBy: "\n")
        }
        if startWords.isEmpty {
            startWords.append("Empty")
        }
        
        refreshWord()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    @objc func refreshWord() {
        usedWords.removeAll()
        tableView.reloadData()
        rootWord = startWords.randomElement()!
        title = "Define New Words - \(rootWord!)"
    }
    
    @objc func addWord() {
        let alertController = UIAlertController(title: "Tell me a new word :)", message: nil, preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Add", style: .default) {[weak alertController, weak self] action in
            if let newWord = alertController?.textFields?[0].text {
                if !newWord.isEmpty {
                    self?.checkWord(newWord)
                }
            }
        })
        
        present(alertController, animated: true)
    }
    
    func checkWord(_ newWord: String) {
        if isPossible(newWord) {
            if isOriginal(newWord) {
                if isReal(newWord) {
                    let indexPath = IndexPath(row: 0, section: 0)
                    
                    usedWords.insert(newWord, at: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    showError(title: "\(newWord) is not real :(", message: "Please try again")
                }
            } else {
                showError(title: "\(newWord) is not original :(", message: "Please try again")
            }
        } else {
            showError(title: "\(newWord) is not possible :(", message: "Please try again")
        }
    }
    
    func isPossible(_ newWord: String) -> Bool {
        var checkWord = rootWord
        
        for letter in newWord {
            if let position = checkWord?.firstIndex(of: letter) {
                checkWord?.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(_ newWord: String) -> Bool {
        return !usedWords.contains(newWord)
    }
    
    func isReal(_ newWord: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: newWord.utf16.count)
        let misspeled = checker.rangeOfMisspelledWord(in: newWord, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspeled.location == NSNotFound
    }
    
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Continue", style: .default))
        
        present(alertController, animated: true)
    }
}
