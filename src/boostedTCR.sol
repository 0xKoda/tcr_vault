pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

interface IFERC20 {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);
}

abstract contract boostedTCR is ERC20, ERC4626 {
    //the underlying token the vault accepts
    ERC20 public immutable UNDERLYING;
    IFERC20 public immutable fToken;

    mapping(address => uint256) balances;

    constructor(ERC20 underlying, IFERC20 _fERC20)
        ERC4626(underlying, "bTCR", "bTCR")
    {
        UNDERLYING = underlying;
        // todo set fToken addr after pool creation
        fToken = _fERC20;
    }

    function afterDeposit(uint256 amount, uint256 shares) internal override {
        UNDERLYING.approve(address(fToken), 100);
        assert(fToken.mint(amount) == 0);
        balances[msg.sender] += amount;
    }

    function beforeWithdraw(uint256 amount, uint256 shares) internal override {
        assert(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        require(fToken.redeem(amount) == 0, "something went wrong");
    }
}
