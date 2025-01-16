import UIKit

class MoviesViewController: UIViewController {
    private let viewModel = MoviesViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(cellType: NowPlayingCell.self)
        collectionView.register(cellType: PopularCell.self)
        collectionView.register(supplementaryViewType: SectionHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        title = "TMDB Movies"
        view.backgroundColor = .systemBackground
        
        view.addSubviews(collectionView, loadingIndicator)
        
        loadingIndicator.centerInSuperview()
        collectionView.pinToSuperview()
    }
    
    private func setupBindings() {
        fetchMovies()
    }
    
    private func fetchMovies() {
        loadingIndicator.startAnimating()
        viewModel.fetchNowPlaying(loadMore: false) { [weak self] in
            self?.viewModel.fetchPopular(loadMore: false) { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        if let error = viewModel.error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        collectionView.reloadData()
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return self?.createNowPlayingSection()
            case 1:
                return self?.createPopularSection()
            default:
                return nil
            }
        }
        return layout
    }
    
    private func createNowPlayingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(280))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createPopularSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

extension MoviesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.nowPlayingMovies.count
        case 1:
            return viewModel.popularMovies.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell: NowPlayingCell = collectionView.dequeueReusableCell(for: indexPath)
            let movie = viewModel.nowPlayingMovies[indexPath.item]
            cell.configure(with: movie)
            return cell
        case 1:
            let cell: PopularCell = collectionView.dequeueReusableCell(for: indexPath)
            let movie = viewModel.popularMovies[indexPath.item]
            cell.configure(with: movie)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: SectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        header.titleLabel.text = indexPath.section == 0 ? "Now Playing" : "Popular"
        return header
    }
}

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie: Movie
        switch indexPath.section {
        case 0:
            movie = viewModel.nowPlayingMovies[indexPath.item]
        case 1:
            movie = viewModel.popularMovies[indexPath.item]
        default:
            return
        }
        
        let detailsVC = MovieDetailsViewController(movie: movie, viewModel: viewModel)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.item == viewModel.nowPlayingMovies.count - 1 {
                viewModel.fetchNowPlaying(loadMore: true) { [weak self] in
                    self?.updateUI()
                }
            }
        case 1:
            if indexPath.item == viewModel.popularMovies.count - 1 {
                viewModel.fetchPopular(loadMore: true) { [weak self] in
                    self?.updateUI()
                }
            }
        default:
            break
        }
    }
}
