//SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import {IERC20} from "./IERC20.sol";


/**
 * This is an ERC-20 standard token.
 * the tokenFactory deploys this contract (i_factory)
 *The tokenFactory (The deployer) is the owner of this token.
 * The token name, symbol and total supply are gotten from the TokenFactory
 contract where this Token contract is called and the values are put in.
 * @title Token
 * @author Southrays
 * @notice The creator of the contract is different from the deployer.
 */

contract Token is IERC20 {
    //////////////////////////////////
    /////      Variables       //////
    ////////////////////////////////
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public s_totalSupply;
    address public immutable i_factory;

    mapping (address => uint) public s_balances;
    mapping (address => mapping (address => uint)) private s_allowances;



    ///////////////////////////////
    /////      Events       //////
    /////////////////////////////
    event Mint( address indexed user, uint256 indexed amount);

    event Burn( address indexed from, uint256 indexed amount);

    event Transfer(
        address indexed sender,
        address indexed receiver,
        uint256 indexed _amount
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed amount
    );


    ////////////////////////////////////
    /////      Constructor       //////
    //////////////////////////////////
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        s_totalSupply = _initialSupply;
        i_factory = msg.sender;

        s_balances[msg.sender] = _initialSupply;
        emit Mint(address(0), _initialSupply);
        emit Transfer(address(0), msg.sender, _initialSupply);
    }



    //////////////////////////////////
    /////      Modifiers       //////
    ////////////////////////////////
    modifier onlyFactory{
        require (msg.sender == i_factory, "Must Be Factory");
        _;
    }



    ///////////////////////////////////////////
    /////      External Functions       //////
    /////////////////////////////////////////
    /**
     * This Function transfers token from one user to another.
     * This person who calls this function is the sender of the Tokens.
     * this function ensures that the sender has the amount of Tokens they
       want to send.
     * When the transaction has been sent, the transaction event is then
       recorded.
     * @param _to This is who the Tokens are being sent to.
     * @param _amount This is the Amount of Tokens to be sent
     */
    function transfer(address _to, uint256 _amount) external override returns (bool) {
        require(_to != address(0), "invalid address");
        require(s_balances[msg.sender] >= _amount, "You do not have enough tokens");

        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }


    /**
     * This Function transfers token from one user to another.
     * This person who calls this function succesfully is the Spender who
     has been approved by a token holder to spend some of their tokens.
     * this function ensures that the user sending is allowed to send the
     amount of Tokens they are trying to send.
     * When the transaction has been sent, the transaction event is then
       recorded. 
     * @param _from this is the sender of the Tokens.
     * @param _to This is who the Tokens are being sent to.
     * @param _amount This is the Amount of Tokens to be sent
     */
    function transferFrom(address _from, address _to, uint256 _amount) external override returns (bool) {
        require(_to != address(0), "invalid address");
        require(s_balances[_from] >= _amount, "insufficient balance");
        
        if (msg.sender != i_factory) {
            require(s_allowances[_from][msg.sender] >= _amount, "insufficient allowance");
        }

        s_balances[_from] -= _amount;
        s_balances[_to] += _amount;
        s_allowances[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }


    /**
     * This function makes it possible for a token holder to allow another user
     (spender) to spend some of the token holder's token.
     * @param _spender This is the user who is being allowed by the token holder
     to spend some of their tokens.
     * @param _amount This is the amount the token holder allows the spender to
     be able to spend. 
     */
    function approve(address _spender, uint256 _amount) external override returns (bool) {
        require(_spender != address(0), "invalid address");
        require (s_balances[msg.sender] >= _amount, "You do not have enough tokens");

        s_allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


    /**
     * This function burns Tokens.
     * Transaction events are stored when succesful.
     * @param _amount the amount of tokens to be burnt.
     */
    function burn(uint256 _amount) external onlyFactory returns (bool) {
        require (s_balances[i_factory] >= _amount, "You Do Not Have Enough Tokens");
        s_totalSupply -= _amount;
        s_balances[i_factory] -= _amount;
        emit Burn(i_factory, _amount);
        emit Transfer(i_factory, address(0), _amount);
        return true;
    }



    //////////////////////////////////////////////
    /////      Pure & View Functions       //////
    ////////////////////////////////////////////
    /**
     * This function displays the overall supply of Tokens.
     */
    function totalSupply() external view override returns (uint256) {
        return s_totalSupply;
    }

    /**
     * This Function displays how much Token a user has.
     * @param user This is the wallet address of the user, we check to
       see how much Token the user has.
     */
    function balanceOf(address user) external view override returns (uint256 balance) {
        return s_balances[user];
    }

    
    /**
     * @dev Returns the remaining number of tokens `spender` is allowed 
     * to spend on behalf of `owner` through {transferFrom}.
     * This is zero by default and changes when {approve} or 
     * {transferFrom} is called.
     * @param _owner The address of the token holder.
     * @param _spender The address of the spender.
     */
    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return s_allowances[_owner][_spender];
    }
}