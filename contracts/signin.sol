pragma solidity ^0.4.23;

contract SignIn {
    using SafeMath for uint256;

    address public owner;
    uint256 public gloableTime;
    uint256 public secondsPerDay;
    uint256 public upperLimit;
    uint256 private globalSalt;
    bool SIGNIN;

    struct User {
        uint256 signInTime;
        uint256 amount;
        uint256 addUp;
        uint256 times;
    }

    mapping (address => User ) user;

    constructor()
    public
    {
        owner = msg.sender;
        secondsPerDay=86400;
        gloableTime=1545667200;
        globalSalt=1024;
        upperLimit=10;
        SIGNIN=false;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"ERROR_ONLY_OWNER");
        _;
    }

    function setGloableTime(uint256 time)
    onlyOwner()
    public
    {
        require(time>gloableTime && time < now,"ERROR_IN_TIME");
        gloableTime = time;
    }

    function setGlobalSalt(uint256 salt)
    onlyOwner()
    public
    {
        globalSalt=salt;
    }

    function setSignIn(bool can)
    onlyOwner()
    public
    {
        SIGNIN=can;
    }

    function setUpper(uint256 upper)
    onlyOwner()
    public
    {
        upperLimit=upper;
    }

    function calculateExactGlobalTime()
    private
    returns(uint256)
    {

        while( now - gloableTime > secondsPerDay)
        {
            gloableTime += secondsPerDay;
        }

        return gloableTime;

    }

    function calculateAndSetGlobalTime()
    private
    {
        uint256 newTime=calculateExactGlobalTime();

        if(newTime != gloableTime){
            gloableTime = newTime;
        }

    }

    function getUserSignStatus(address userAddress)
    view public returns(bool status,uint256 signInTime,uint256 amount,uint256 times,uint256 addUp)
    {
        status=false;
        if(user[userAddress].signInTime>gloableTime)
        {
            status=true;
        }
        return(status,user[userAddress].signInTime,user[userAddress].amount,user[userAddress].times,user[userAddress].addUp);
    }

    event onSignIn(
        address user,
        uint256 amount,
        uint256 addUp,
        uint256 signInTime,
        uint256 times
    );

    /**
    * @dev generates a random number between 0-99 and checks to see if thats
    * resulted in an airdrop win
    * @return do we have a winner?
    */
    function random(uint256 salt)
    private
    view
    returns(uint)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(

                (block.timestamp).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number).add
                (globalSalt).add
                (address(this).balance).add
                (salt)

            )));

        return ((seed % upperLimit)+1);
    }

    function signIn(uint256 salt)
    public
    returns
        (address ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 )
    {
        require(SIGNIN==true,'ERROR_SIGN_IN_BANNED');
        address userAddress=msg.sender;
        calculateAndSetGlobalTime();

        require(user[userAddress].signInTime < gloableTime,"ERROR_ALREADY_SIGN_IN");
        uint256 amount=random(salt);

        user[userAddress].signInTime = now;
        user[userAddress].amount = amount;
        user[userAddress].addUp = user[userAddress].addUp.add(amount);
        user[userAddress].times = user[userAddress].times+1;

        emit onSignIn( userAddress, amount, user[userAddress].addUp, user[userAddress].signInTime, user[userAddress].times);
        return(userAddress, amount, user[userAddress].addUp, user[userAddress].signInTime, user[userAddress].times);
    }


}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
