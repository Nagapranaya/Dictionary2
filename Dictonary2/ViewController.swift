//
//  ViewController.swift
//  Dictonary2
//
//  Created by Pranaya on 8/16/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     var words = [String]()
    
    @IBOutlet weak var wordTextField: UITextField!
    
    @IBOutlet weak var WordMeaningDisplayLabel: UILabel!
    
    @IBOutlet weak var wordsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchCoreData { x in
            print(x!)
            if let words = x{
                for w in words{
                    print(w.meaning!)
                    print(w.word!)
                    self.words.append(w.word!)
                }
            }
        }
        
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        fetchMeaning(completionHandler: { dictonaryArray in
            print(dictonaryArray)
            let x = dictonaryArray[0].meanings[0].definitions[0]
            print(x)
            DispatchQueue.main.async {
                self.WordMeaningDisplayLabel.text = x.definition
                self.words.append(self.wordTextField.text!)
                self.wordsTable.reloadData()
                addCoreData(word: self.wordTextField.text!, meaning: x.definition)
            }
            
            
        }, word: wordTextField.text!)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let acell = self.wordsTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DictonaryTableViewCell
        acell.wordsLabel.text = self.words[indexPath.row]
        return acell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fetchMeaning(completionHandler: { dictonaryArray in
            print(dictonaryArray)
            let x = dictonaryArray[0].meanings[0].definitions[0]
            print(x)
            DispatchQueue.main.async {
                self.WordMeaningDisplayLabel.text = x.definition
            }
            
        }, word: self.words[indexPath.row])
    }
    
}

func fetchMeaning(completionHandler: @escaping ([Dictonary]) -> Void, word: String){
    let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/" + word)!
    let task = URLSession.shared.dataTask(with: url , completionHandler: { (data,response,error) in
        if let error =  error{
            print("error in fetching meaning: \(error)")
            return
        }
        guard let httpresponse = response as? HTTPURLResponse ,(200...299).contains(httpresponse.statusCode) else{
            print("error in response: \(String(describing: response))")
            return
        }
        if let data = data
        {
           print(String(data: data , encoding: .utf8)!)
            do {
            let dictonaryArray = try JSONDecoder().decode([Dictonary].self, from: data)
                print(dictonaryArray)
                completionHandler(dictonaryArray)
            }
            catch let jsonErr {
                print("error printing json data", jsonErr)
            }
        }
    })
    task.resume()
}


func addCoreData(word: String, meaning: String) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let words = Words(context: context)
    words.word = word
    words.meaning = meaning
    do {
        try context.save()
    } catch {
        print("error-Saving data")
    }
}


func fetchCoreData(onSuccess: @escaping ([Words]?) -> Void) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    do {
        let items = try context.fetch(Words.fetchRequest()) as? [Words]
        onSuccess(items)
    } catch {
        print("error-Fetching data")
    }
}

func deleteCoreData(indexPath: Int, items: [Words]) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataToRemove = items[indexPath]
    context.delete(dataToRemove)
    do {
        try context.save()
    } catch {
        print("error-Deleting data")
    }
}
