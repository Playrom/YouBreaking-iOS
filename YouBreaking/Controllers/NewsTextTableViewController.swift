//
//  NewsTextTableViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 28/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class NewsTextTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Class Elements
    var delegate : HeightDelegate?
    var text : String?
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = text
        label.textAlignment = .justified
        label.isEnabled = false
        
        label.setNeedsLayout()
        label.setNeedsDisplay()
        label.layoutSubviews()
        
        if let text = text{
            textView.text = text
            textView.textAlignment = .justified
            textView.setNeedsLayout()
            textView.setNeedsDisplay()
            textView.layoutSubviews()
        }
        
        self.tableView.bounces = false
    }
    
    // MARK: - Table View Data Source
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.heightChanged(height: scrollView.contentOffset.y, animated : false, completition : nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.separatorInset = .zero
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        return cell
    }
}
