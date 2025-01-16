import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: String(describing: cellType))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Unable to dequeue \(String(describing: T.self))")
        }
        return cell
    }
    
    func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind kind: String) {
        register(supplementaryViewType.self, 
                forSupplementaryViewOfKind: kind,
                withReuseIdentifier: String(describing: supplementaryViewType))
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: T.self),
            for: indexPath) as? T else {
            fatalError("Unable to dequeue \(String(describing: T.self))")
        }
        return view
    }
}
