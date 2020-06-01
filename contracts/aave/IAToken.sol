// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

/**
 * @title Aave ERC20 AToken
 *
 * @dev Implementation of the interest bearing token for the DLP protocol.
 * @author Aave
 */
interface IAToken {

    /**
    * @dev emitted after the redeem action
    * @param _from the address performing the redeem
    * @param _value the amount to be redeemed
    * @param _fromBalanceIncrease the cumulated balance since the last update of the user
    * @param _fromIndex the last index of the user
    **/
    event Redeem(
        address indexed _from,
        uint256 _value,
        uint256 _fromBalanceIncrease,
        uint256 _fromIndex
    );

    /**
    * @dev redeems aToken for the underlying asset 卖掉aToken赎回原代币
    * @param _amount the amount being redeemed
    **/
    function redeem(uint256 _amount) external;

    /**
    * @dev calculates the balance of the user, which is the
    * principal balance + interest generated by the principal balance + interest generated by the redirected balance
    * @param _user the user for which the balance is being calculated
    * @return the total balance of the user 包含利息的余额
    **/
    function balanceOf(address _user) external view returns (uint256);

    /**
    * @dev returns the principal balance of the user. The principal balance is the last
    * updated stored balance, which does not consider the perpetually accruing interest.
    * @param _user the address of the user
    * @return the principal balance of the user 无利息的值
    **/
    function principalBalanceOf(address _user) external view returns (uint256);


}