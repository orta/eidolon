import UIKit

class ConfirmYourBidArtsyLoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var confirmCredentialsButton: UIButton!

    class func instantiateFromStoryboard() -> ConfirmYourBidArtsyLoginViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ConfirmYourBidArtsyLogin) as ConfirmYourBidArtsyLoginViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let inputIsEmail = emailTextField.rac_textSignal().map(isEmailAddress)
        let passwordExists = passwordTextField.rac_textSignal().map(hasStringLength)

        RAC(confirmCredentialsButton, "enabled") <~  RACSignal.combineLatest([inputIsEmail, passwordExists]){ ( ) -> AnyObject! in
            //  leaving for Ash not sure how the inputs into this closure works
            return true
        }

//        XAppRequest(endpoint, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(SaleArtwork.self).doNext({ [weak self] (_) -> Void in


        let loginCommand = confirmCredentialsButton.rac_command = RACCommand(enabled: inputIsEmail, signalBlock: { (sender) -> RACSignal! in
            // also a bit confused here too actually
        })

        loginCommand.executionSignals.subscribeNext(  { [weak self] (layout) -> Void in
            let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: emailTextField.text, password: passwordTextField.text)
            Provider.DefaultProvider().filterSuccessfulStatusCodes().mapJSON().doNext({ [weak self] (_) -> Void in

                println("AUTHD");
            })
        })



    }
}


private extension ConfirmYourBidArtsyLoginViewController {

    @IBAction func dev_hasCardTapped(sender: AnyObject) {
        self.performSegue(.EmailLoginConfirmedHighestBidder)
    }

    @IBAction func dev_noCardFoundTapped(sender: AnyObject) {
        self.performSegue(.ArtsyUserHasNotRegisteredCard)
    }

    func isEmailAddress(text:AnyObject!) -> AnyObject! {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        return testPredicate?.evaluateWithObject(text) == false
    }

    func hasStringLength(text:AnyObject!) -> AnyObject! {
        return countElements(text as String) != 0
    }

}