// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/**
@title AgicAddressesProvider interface
@notice provides the interface to fetch the Agic address
 */

interface IAgicAddressesProvider {

    function getAgicFundPoolWhiteList() external view returns (address[] memory);

    function verifyFundPoolWhiteList(address) external view returns (bool);

    function addAgicFundPoolWhiteList(address) external;

    function subAgicFundPoolWhiteList(address) external;

    function getAgicFundPool() external view returns (address payable);

    function setAgicFundPool(address payable pool) external;

    function getAgic() external view returns (address);

    function setAgic(address agic) external;

    function getAgicInterestCard() external view returns (address);

    function setAgicInterestCard(address agicInterestCard) external;

    //Not used yet
    function getExtendAddressesProvider() external view returns (address);

    //Not used yet
    function setExtendAddressesProvider(address extend) external;


}
