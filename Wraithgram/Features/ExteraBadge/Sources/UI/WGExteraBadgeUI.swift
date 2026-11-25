import Foundation
import UIKit

/// A small pill drawn next to a name (chat list / profile header).
///
/// The real exteraGram badge is a remote document (`badge.documentId`). Resolving an arbitrary
/// Telegram document id to a local UIImage requires a Telegram file-reference context, which a
/// feature module does not have in the header layout path. To keep the patch safe and honest, the
/// pill shows the server's own `badge.text` (or a localized status name); no badge artwork is
/// faked locally. Swap this view for an AsyncDisplayKit image node if you later add a document
/// resolver in Wraithgram's own layer.
final class WGExteraBadgePillView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.label.font = .systemFont(ofSize: 11, weight: .semibold)
        self.label.textAlignment = .center
        self.label.textColor = .white
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(text: String?, color: UIColor) {
        guard let text, !text.isEmpty else {
            self.isHidden = true
            return
        }
        self.isHidden = false
        self.backgroundColor = color.withAlphaComponent(0.85)
        self.label.text = text
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textSize = self.label.sizeThatFits(CGSize(width: size.width - 10, height: size.height - 2))
        return CGSize(width: ceil(textSize.width) + 10, height: ceil(textSize.height) + 2)
    }
}
