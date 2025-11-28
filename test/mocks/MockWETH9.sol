// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

contract MockWETH9 {
    //////////////////////////////
    /////     Variables     /////
    ////////////////////////////
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;



    ///////////////////////////
    /////     Events     /////
    /////////////////////////
    event Deposit(address indexed dst, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Approval(address indexed src, address indexed guy, uint wad);



    ///////////////////////////////////////
    /////     External Functions     /////
    /////////////////////////////////////
    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }


    function approve(address guy, uint wad) external returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }


    function transfer(address dst, uint wad) external returns (bool) {
        require(balanceOf[msg.sender] >= wad, "insufficient");
        balanceOf[msg.sender] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(msg.sender, dst, wad);
        return true;
    }
}
