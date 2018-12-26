pragma solidity ^0.4.23;

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
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

contract basicEvents {
    event onDeposit(
        address user,
        uint256 value
    );


    event onWithdraw(
        address user,
        uint256 value
    );


    event onUpdateUserPlayingStatus(
        address userAddress,
        uint256 lucky,
        uint256 redID
    );

    event onUpdateUserPlayingStatusMulti(
        address userAddress,
        uint256 lucky,
        uint256 redID
    );

    event onUploadRedResult(
        address player2,
        uint256 value2,
        address player3,
        uint256 value3,
        address player4,
        uint256 value4,
        address player5,
        uint256 value5,
        uint256 redID
    );

    event onUploadPoolResult(
        address luckyBoy,
        uint256 subValue,
        uint256 dividends,
        uint256 lucky,
        address aff,
        uint256 affEarn,
        uint256 comEarn,
        uint256 redID
    );

    event onUploadShareBonus(
        address userAddress,
        uint256 value,
        uint256 balance
    );

    event onGetAndClearDividendsPool(
        uint256 dividendsPool
    );

    event onUpdateFiveUserBalance(
        address user1,
        uint256 value1,
        address user2,
        uint256 value2,
        address user3,
        uint256 value3,
        address user4,
        uint256 value4,
        address user5,
        uint256 value5
    );

    event onSignIn(
        address user,
        uint256 amount
    );
}

contract Basic is basicEvents {
    using SafeMath for uint256;
    address public owner;
    address public admin;
    address public com;
    bool DEPOSIT;
    bool WITHDRAW;
    bool SIGNIN;

    constructor()
    public
    {
        owner=msg.sender;
        admin=msg.sender;
        com=msg.sender;
        DEPOSIT=false;
        WITHDRAW=false;
        SIGNIN=false;
    }

    struct User {
        uint256 balance;
        uint redID;
        uint reds;
    }

    mapping(address => User) public userInfo;
    uint256 dividendsPool;
    uint256 luckyPool;

    //==============================================================================
    //     _ _  _  _|. |`. _  _ _  .
    //    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)
    //==============================================================================

    /**
     * @dev prevents contracts from interacting with Basic
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "ERROR_ONLY_HUNMAN");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"ERROR_ONLY_OWNER");
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == owner || msg.sender == admin,"ERROR_ONLY_ADMIN");
        _;
    }
    //==============================================================================
    //     _    |_ |. _   |`    _  __|_. _  _  _  .
    //    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)
    //====|=========================================================================

    function setAdmin(address adminAddress)
    isHuman()
    onlyOwner()
    public
    {
        admin=adminAddress;
    }

    function setCom(address comAddress)
    isHuman()
    onlyOwner()
    public
    {
        com=comAddress;
    }

    function deposit()
    isHuman()
    public
    payable
    {
        require(DEPOSIT==true,'ERROR_DEPOSIT_BANNED');
        address user = msg.sender;
        uint256 value = msg.value;

        require(value>0,'ERROR_INVALID_DEPOSIT_VALUE');

        userInfo[user].balance=userInfo[user].balance.add(value);

        emit basicEvents.onDeposit(user,value);
    }

    function withdraw()
    isHuman()
    public
    {
        require(WITHDRAW==true,'ERROR_WITHDRAW_BANNED');

        address user = msg.sender;
        require(userInfo[user].balance>0,'ERROR_INVALID_WITHDRAW_VALUE');
        require(userInfo[user].reds==0,'ERROR_IN_GAME');

        user.transfer(userInfo[user].balance);
        emit basicEvents.onWithdraw(user,userInfo[user].balance);
        userInfo[user].balance=0;
    }

    function updateUserPlayingStatus(address userAddress,uint256 lucky,uint256 redID)
    onlyAdmin()
    public
    {
        require(redID>0,'ERROR_INVALID_REDID');
        require(userInfo[userAddress].reds==0,'ERROR_IN_GAME');
        require(luckyPool>=lucky,'ERROR_VALUE');
        userInfo[userAddress].redID=redID;
        userInfo[userAddress].reds=userInfo[userAddress].reds.add(1);

        if(lucky>0){
            luckyPool=luckyPool.sub(lucky);
            userInfo[userAddress].balance = userInfo[userAddress].balance.add(lucky);
        }

        emit basicEvents.onUpdateUserPlayingStatus(userAddress,lucky,redID);
    }

    function uploadRedResult(address player2,uint256 value2,address player3,uint256 value3,address player4,uint256 value4,address player5,uint256 value5)
    onlyAdmin()
    public
    {
        require(userInfo[player2].reds>0,'ERROR_NOT_IN_GAME');
        require(userInfo[player3].reds>0,'ERROR_NOT_IN_GAME');
        require(userInfo[player4].reds>0,'ERROR_NOT_IN_GAME');
        require(userInfo[player5].reds>0,'ERROR_NOT_IN_GAME');

        userInfo[player2].balance=userInfo[player2].balance.add(value2);
        userInfo[player3].balance=userInfo[player3].balance.add(value3);
        userInfo[player4].balance=userInfo[player4].balance.add(value4);
        userInfo[player5].balance=userInfo[player5].balance.add(value5);

        uint256 redID=userInfo[player2].redID;

        userInfo[player2].reds=userInfo[player2].reds.sub(1);
        userInfo[player3].reds=userInfo[player3].reds.sub(1);
        userInfo[player4].reds=userInfo[player4].reds.sub(1);
        userInfo[player5].reds=userInfo[player5].reds.sub(1);

        emit basicEvents.onUploadRedResult( player2,value2, player3,value3, player4,value4, player5,value5,redID);
    }

    function uploadPoolResult(address luckyBoy,uint256 subValue,uint256 dividends,uint256 lucky,address aff,uint256 affEarn,uint256 comEarn)
    onlyAdmin()
    public
    {
        require(userInfo[luckyBoy].reds>0,'ERROR_NOT_IN_GAME');
        userInfo[luckyBoy].balance=userInfo[luckyBoy].balance.sub(subValue);

        uint256 redID=userInfo[luckyBoy].redID;

        userInfo[luckyBoy].reds=userInfo[luckyBoy].reds.sub(1);

        dividendsPool=dividendsPool.add(dividends);
        luckyPool=luckyPool.add(lucky);

        if(affEarn !=0){
            userInfo[aff].balance=userInfo[aff].balance.add(affEarn);
        }

        com.transfer(comEarn);

        emit basicEvents.onUploadPoolResult( luckyBoy,subValue,dividends, lucky, aff, affEarn, comEarn,redID);
    }

    function getAndClearDividendsPool()
    onlyAdmin()
    public
    returns(uint256)
    {
        uint256 data=dividendsPool;
        dividendsPool=0;
        emit basicEvents.onGetAndClearDividendsPool(data);
        return data;
    }

    function uploadShareBonus(address userAddress,uint256 value)
    onlyAdmin()
    public{
        userInfo[userAddress].balance=userInfo[userAddress].balance.add(value);
        emit basicEvents.onUploadShareBonus(userAddress,value,userInfo[userAddress].balance);
    }

    function updateFiveUserBalance(address user1,uint256 value1,address user2,uint256 value2,address user3,uint256 value3,address user4,uint256 value4,address user5,uint256 value5)
    onlyAdmin()
    public{
        userInfo[user1].balance=userInfo[user1].balance.add(value1);
        userInfo[user2].balance=userInfo[user2].balance.add(value2);
        userInfo[user3].balance=userInfo[user3].balance.add(value3);
        userInfo[user4].balance=userInfo[user4].balance.add(value4);
        userInfo[user5].balance=userInfo[user5].balance.add(value5);
        emit basicEvents.onUpdateFiveUserBalance(user1,value1,user2,value2,user3,value3,user4,value4,user5,value5);
    }

    function getUserStatus(address userAddress)
    public
    view
    returns(uint256 balance,uint256 redID,uint reds){
        return(userInfo[userAddress].balance,userInfo[userAddress].redID,userInfo[userAddress].reds);
    }

    function getGlobalInfo()
    public
    view
    returns(uint256 ,uint256 ,uint256 ,bool ,bool,bool){
        return(address(this).balance,dividendsPool,luckyPool,DEPOSIT,WITHDRAW,SIGNIN);
    }

    function switchCharge(bool deposit,bool withdraw,bool signIn)
    onlyAdmin()
    public
    {
            DEPOSIT=deposit;
        WITHDRAW=withdraw;
        SIGNIN=signIn;
    }

    function close()
    onlyOwner()
    public
    {
        DEPOSIT=false;
        WITHDRAW=false;
        selfdestruct(owner);
    }

    function updateUserPlayingStatusMulti(address userAddress,uint256 lucky,uint256 redID)
    onlyAdmin()
    public
    {
        require(redID>0,'ERROR_INVALID_REDID');
        require(luckyPool>=lucky,'ERROR_VALUE');
        userInfo[userAddress].redID=redID;
        userInfo[userAddress].reds=userInfo[userAddress].reds.add(1);

        if(lucky>0){
            luckyPool=luckyPool.sub(lucky);
            userInfo[userAddress].balance = userInfo[userAddress].balance.add(lucky);
        }

        emit basicEvents.onUpdateUserPlayingStatusMulti(userAddress,lucky,redID);
    }

    function signIn()
    public
    returns
    (uint256)
    {
        require(SIGNIN==true,'ERROR_SIGN_IN_BANNED');
        address user=msg.sender;
        uint256 amount=airdrop();
        emit basicEvents.onSignIn(user,amount);

        return amount;
    }

    /**
    * @dev generates a random number between 0-99 and checks to see if thats
    * resulted in an airdrop win
    * @return do we have a winner?
    */
    function airdrop()
    private
    view
    returns(uint)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(

                (block.timestamp).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number).add
                (block.number).add
                (address(this).balance)

            )));

        return ((seed % 10)+1);

    }

}



