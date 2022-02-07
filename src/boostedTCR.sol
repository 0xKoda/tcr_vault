pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

abstract contract boostedTCR is ERC20, ERC4626 {
    //the underlying token the vault accepts
    ERC20 public immutable UNDERLYING;
    ERC20 public immutable fToken;

    mapping(address => uint256) balances;

    constructor(ERC20 underlying) ERC4626(underlying, "bTCR", "bTCR") {
        UNDERLYING = ERC20(underlying);
        // todo set fToken addr after pool creation
        fToken = ERC20(0x0...);
    }

    function afterDeposit(uint256 amount, uint256 shares) internal override {
        UNDERLYING.approve(address(fToken), 100);
        assert(fToken.mint(amount) == 0);
        balances[msg.sender] += amount;
    }

    function beforeWithdrawal(uint256 amount, uint256 shares) internal override {
        assert(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        require(fToken.redeem(amount) == 0, "something went wrong");
    }
}
