import UIKit

class InstallmentsNumberOfTermsChooserTableViewController: UITableViewController {
    
    var numberOfTerms: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfTerms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfTermCell", for: indexPath)
        cell.textLabel?.text = "\(numberOfTerms[indexPath.row])"
        return cell
    }
    
}
