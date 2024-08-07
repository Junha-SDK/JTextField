import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift

open class JTextField: UITextField {

    private let disposeBag = DisposeBag()

    public var errorFont: UIFont?
    public var underlineColor: UIColor
    public var errorColor: UIColor
    public var focusUnderlineColor: UIColor
    public var animationDuration: TimeInterval

    public let underlineView = UIView()
    public let errorLabel = UILabel()
    public let deleteButton = UIButton(type: .custom)

    public var showImage: Bool = false {
        didSet {
            deleteButton.isHidden = !showImage
        }
    }

    public var showError: Bool = false {
        didSet {
            errorLabel.isHidden = !showError
            underlineView.backgroundColor = showError ? errorColor : underlineColor
        }
    }

    public var errorMessage: String? {
        didSet {
            errorLabel.text = errorMessage
        }
    }

    public override var placeholder: String? {
        didSet {
            super.placeholder = placeholder
        }
    }

    public init(
        frame: CGRect = .zero,
        errorFont: UIFont = UIFont.systemFont(ofSize: 12),
        underlineColor: UIColor = .gray,
        errorColor: UIColor = .red,
        focusUnderlineColor: UIColor = .blue,
        animationDuration: TimeInterval = 0.3
    ) {
        self.errorFont = errorFont
        self.underlineColor = underlineColor
        self.errorColor = errorColor
        self.focusUnderlineColor = focusUnderlineColor
        self.animationDuration = animationDuration
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        configure()
        bind()

        self.tintColor = .black
        errorLabel.font = errorFont
        underlineView.backgroundColor = underlineColor
        errorLabel.textColor = errorColor
        errorLabel.isHidden = true

        if #available(iOS 13.0, *) {
            deleteButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        } else {
            print("13 이하는 아직 지원하지 않습니다.")
        }
        deleteButton.isHidden = true
    }

    private func configure() {
        [underlineView, errorLabel, deleteButton].forEach { self.addSubview($0) }

        underlineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        errorLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(underlineView.snp.bottom).offset(8)
        }

        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }

    private func bind() {
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.text = ""
                self?.deleteButton.isHidden = true
            })
            .disposed(by: disposeBag)

        self.rx.controlEvent(.editingDidBegin).asObservable().subscribe(onNext: { [weak self] _ in
            UIView.animate(withDuration: self?.animationDuration ?? 0.3) {
                self?.underlineView.backgroundColor = self?.focusUnderlineColor
            }
        }).disposed(by: disposeBag)

        self.rx.controlEvent(.editingDidEnd).asObservable().subscribe(onNext: { [weak self] _ in
            UIView.animate(withDuration: self?.animationDuration ?? 0.3) {
                self?.underlineView.backgroundColor = self?.text?.isEmpty ?? true ? self?.underlineColor : self?.focusUnderlineColor
            }
            self?.deleteButton.isHidden = self?.text?.isEmpty ?? true
        }).disposed(by: disposeBag)
    }
}
