import Quick
import Nimble

class XAppTokenSpec: QuickSpec {
    override func spec() {
        let defaults = NSUserDefaults()
        let token = XAppToken()
        
        it("returns correct data") {
            let key = "some key"
            let expiry = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key, expiry)
            
            expect(token.token).to(equal(key))
            expect(token.expiry).to(equal(expiry))
        }
        
        it("correctly calculates validity for expired tokens") {
            let key = "some key"
            let past = NSDate(timeIntervalSinceNow: -1000)
            setDefaultsKeys(defaults, key, past)
            
            expect(token.isValid).to(beFalsy())
        }
        
        it("correctly calculates validity for non-expired tokens") {
            let key = "some key"
            let future = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key, future)
            
            expect(token.isValid).to(beTruthy())
        }
        
        it("correctly calculates validity for empty keys") {
            let key = ""
            let future = NSDate(timeIntervalSinceNow: 1000)
            setDefaultsKeys(defaults, key, future)
            
            expect(token.isValid).to(beFalsy())
        }
        
        it("properly calculates validity for missing tokens") {
            setDefaultsKeys(defaults, nil, nil)
            
            expect(token.isValid).to(beFalsy())
        }
    }
}
