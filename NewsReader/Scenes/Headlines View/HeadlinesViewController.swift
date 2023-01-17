import UIKit
import RxSwift
import RxCocoa
import RxDataSources

private enum Constants {
    static let headlineCell = "headline-cell"
}

final class HeadlinesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
        
    typealias ViewModel = HeadlinesViewModel
    
    let viewModel: ViewModel
    
    private var disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<NewsSection> { (dataSource, tableView: UITableView, indexPath, item) in
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.headlineCell) as! HeadlineCell
        cell.configure(with: item)
        return cell
    }
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
}

private extension HeadlinesViewController {
    
    func configureViews() {
        configureTableView()
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "HeadlineCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.headlineCell)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] ip in
                tableView.deselectRow(at: ip, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .headlines
            .drive(
                tableView.rx.items(dataSource: dataSource)
            )
            .disposed(by: disposeBag)
    }
    
}
