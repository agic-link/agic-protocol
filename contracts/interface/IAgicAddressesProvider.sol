// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

/**
@title AgicAddressesProvider interface
@notice provides the interface to fetch the Agic address
 */

interface IAgicAddressesProvider {

    //todo 添加pool白名单

    function getAgicFundPool() external view returns (address payable);

    function setAgicFundPool(address payable pool) external;

    function getAgic() external view returns (address);

    function setAgic(address agic) external;

    function getAgicEquityCard() external view returns (address);

    function setAgicEquityCard(address agicEquityCard) external;

    //Not used yet
    function getExtendAddressesProvider() external view returns (address);

    //Not used yet
    function setExtendAddressesProvider(address extend) external;


}