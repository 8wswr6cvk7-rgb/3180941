import MapKit
import SwiftUI

final class XilianMKAnnotationView: MKAnnotationView {
    private let spriteWidth = XilianMapAnnotationView.spriteWidth
    private let spriteHeight = XilianMapAnnotationView.spriteHeight
    private let bottomTransparentPadding = XilianMapAnnotationView.bottomTransparentPadding

    private var host: UIHostingController<XilianMapAnnotationView>?

    override var annotation: MKAnnotation? {
        didSet {
            configureIfNeeded()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func configure(with annotation: XilianRouteAnnotation) {
        self.annotation = annotation
        configureIfNeeded()
    }

    private func commonInit() {
        canShowCallout = false
        backgroundColor = .clear
        displayPriority = .required
        collisionMode = .none
        layer.zPosition = 1_000
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        applyAnchorGeometry()
    }

    private func configureIfNeeded() {
        guard let annotation = annotation as? XilianRouteAnnotation else { return }
        applyAnchorGeometry()

        let rootView = XilianMapAnnotationView(
            message: annotation.message,
            state: annotation.animationState
        )

        if let host {
            host.rootView = rootView
        } else {
            let host = UIHostingController(rootView: rootView)
            host.view.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(host.view)
            NSLayoutConstraint.activate([
                host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                host.view.topAnchor.constraint(equalTo: topAnchor),
                host.view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            self.host = host
        }
    }

    private func applyAnchorGeometry() {
        bounds = CGRect(
            x: 0,
            y: 0,
            width: spriteWidth,
            height: spriteHeight
        )
        centerOffset = CGPoint(
            x: 0,
            y: -(spriteHeight / 2) + bottomTransparentPadding
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        annotation = nil
        host?.rootView = XilianMapAnnotationView(message: "", state: .idle)
        applyAnchorGeometry()
    }
}
