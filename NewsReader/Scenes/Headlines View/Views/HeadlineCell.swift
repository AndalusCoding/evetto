import UIKit

final class HeadlineCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bylineLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    
    func configure(
        with viewModel: TopStoryHeadline
    ) {
        titleLabel.text = viewModel.title
        bylineLabel.text = viewModel.byline
        sectionLabel.text = viewModel.section
    }
    
}
