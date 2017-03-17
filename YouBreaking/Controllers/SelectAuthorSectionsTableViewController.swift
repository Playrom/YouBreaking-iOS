//
//  SelectAuthorSectionsTableViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 17/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class SelectAuthorSectionsTableViewController: UITableViewController {

    // MARK: - Class Elements
    var authorId : String?

    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.parent)
        if(indexPath.section == 0 ){
            print(self.parent)
            if let nav = self.parent?.navigationController{
                let vc = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "User Lista Notizie Controller") as! UserListaNotizieController
                vc.id = authorId
                nav.pushViewController(vc, animated: true)
            }
        }
    }
}
