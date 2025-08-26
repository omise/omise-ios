import Foundation
import UIKit

// MARK: - Country Code Picker Controller
class CountryCodePickerController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CountryCodePickerViewModelProtocol
    
    // MARK: - UI Elements
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "CreditCard.search.country.code.hint".localized()
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CountryCodeCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Initialization
    init(viewModel: CountryCodePickerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewModelBindings()
    }
    
    convenience init(selectedCountry: Country, onCountrySelected: @escaping (Country) -> Void) {
        let viewModel = CountryCodePickerViewModel(selectedCountry: selectedCountry)
        
        self.init(viewModel: viewModel)
        
        viewModel.onCountrySelected = onCountrySelected
        viewModel.onCancel = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupSearch()
        viewModel.input.viewDidLoad()
    }
    
    // MARK: - Setup Methods
    private func setupViewModelBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.scrollToSelectedCountry()
            }
        }
        
        viewModel.onCancel = { [weak self] in
            self?.handleCancel()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = viewModel.output.title
    }
    
    private func setupSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        viewModel.input.cancel()
    }
    
    private func handleCancel() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func scrollToSelectedCountry() {
        guard let selectedIndex = viewModel.output.selectedCountryIndex else { return }
        
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        
        // Ensure the table view has finished loading data
        DispatchQueue.main.async { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension CountryCodePickerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeCell", for: indexPath)
        let country = viewModel.output.countries[indexPath.row]
        
        cell.textLabel?.text = "\(country.name) (\(country.phonePrefix))"
        cell.accessoryType = country.code == viewModel.output.selectedCountry.code ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.input.selectCountry(at: indexPath.row)
        handleCancel()
    }
}

// MARK: - Search Results Updater
extension CountryCodePickerController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.input.filterCountries(with: searchText)
    }
}
