//SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

interface IERC20 {

    //////////////////////////////////////////
    /////      External Fuctions       //////
    ////////////////////////////////////////
    /**
     * @dev Transfers `amount` tokens to address `to`.
     * Returns true if successful.
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _amount) external returns (bool);


    /**
     * @dev Approves `spender` to spend `amount` on behalf of the caller.
     * Returns true if successful.
     * Emits an {Approval} event.
     */
    function approve(address _spender, uint256 _amount) external returns (bool);


    /**
     * @dev Transfers `amount` tokens from `from` to `to` using 
     * the allowance mechanism. `amount` is deducted from the caller's allowance.
     * Returns true if successful.
     * Emits a {Transfer} event.
     */
    function transferFrom(address _from, address _to, uint256 _amount) external  returns (bool);



    /////////////////////////////////////////////
    /////      Pure & View Fuctions       //////
    ///////////////////////////////////////////
    /**
     * @dev Returns the total number of tokens in existence.
     */
    function totalSupply() external view returns (uint256);


    /**
     * @dev Returns the remaining number of tokens `spender` is allowed 
     * to spend on behalf of `owner` through {transferFrom}.
     * This is zero by default and changes when {approve} or 
     * {transferFrom} is called.
     */
    function allowance(address _owner, address _spender) external view returns (uint256);


    /**
     * @dev Returns the balance of the given account.
     */
    function balanceOf(address user) external view returns (uint256 balance);
}