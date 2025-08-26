import UIKit

class CountryListController: UIViewController {
    typealias ViewModel = CountryListViewModelProtocol
    
    private struct Style {
        let countryCellIdentifier = "CountryCell"
    }
    
    private var style = Style()
    
    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }
    
    var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }
    
    var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "CreditCard.search.country.hint".localized()
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: style.countryCellIdentifier)
        return tableView
    }()
    
    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSearch()
        
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset search if search bar is empty but we have filtered results
        if searchController.searchBar.text?.isEmpty == true {
            viewModel?.filterCountries(with: "")
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll to selected country after view has fully appeared
        scrollToSelectedRow(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear search when leaving the view to ensure clean state when returning
        searchController.searchBar.text = ""
        viewModel?.filterCountries(with: "")
    }
}

extension CountryListController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredCountries.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: style.countryCellIdentifier, for: indexPath)
        let country = viewModel?.filteredCountries.at(indexPath.row)
        
        cell.textLabel?.text = country?.name ?? ""
        cell.textLabel?.textColor = UIColor.omisePrimary
        
        // Use code comparison for better matching instead of object equality
        let isSelected = viewModel?.selectedCountry?.code == country?.code
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.updateSelectedCountry(at: indexPath.row)
    }
}

// MARK: Setups
private extension CountryListController {
    func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .background
        view.addSubviewAndFit(tableView)
        tableView.reloadData()
    }
    
    func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        tableView.reloadData()
        // Don't scroll here as viewDidAppear will handle it with better timing
    }
    
    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }
    
    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }
    
    func scrollToSelectedRow(animated: Bool) {
        guard let viewModel = viewModel,
              let selectedCountry = viewModel.selectedCountry else { return }
        
        // Ensure we have the selected country in our filtered list
        let index = viewModel.filteredCountries.firstIndex { country in
            // Use code comparison for better matching
            country.code == selectedCountry.code
        }
        
        if let index = index, index < tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
}

// MARK: - Search Results Updater
extension CountryListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel?.filterCountries(with: searchText)
        tableView.reloadData()
        DispatchQueue.main.async {
            self.scrollToSelectedRow(animated: false)
        }
    }
}

#if SWIFTUI_ENABLED
import SwiftUI

// MARK: Preview
struct CountryListViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(
            viewController:
                CountryListController(
                    viewModel: CountryListViewModelMockup()
                )
        )
    }
}
#endif
