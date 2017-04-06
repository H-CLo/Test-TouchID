# Test-TouchID


## Target: 
Sample project to test iOS TouchID

Using **Local Authentication** framework: 

Provides facilities for requesting authentication from users with specified security policies.

## Content:
1. btnTouchIDLocalAuth_onClick
    1. New instance LAContext()
    2. canEvaluatePolicy: Check if the device support Touch ID or not?
    3. evaluatePolicy: Authentication with Touch ID and return

2. btnAddItem_onClick
    1. Create a password as a String
    2. Create *SecAccessControl* with several flags
    3. Create a [NSString : Anyobject] dictionary
    4. Check whether the item in the keychain, if YES, delete it.
    5. Add item to the keychain

3. btnTouchIDKeychainAuth_onClick
    1. Create a [NSString : Anyobject] dictionary
    2. Access item password from keychain
    3. Return result
    
4. btnTouchIDQuitWithTimeout
    1. Create a semophore
    2. Set timeout NSEC_PER_SEC
    3. If timeout, LAContext().invalidate()
