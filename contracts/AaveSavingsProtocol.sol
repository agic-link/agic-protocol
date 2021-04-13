//// SPDX-License-Identifier: MIT
//
//pragma solidity ^0.6.12;
//
//import "@openzeppelin/contracts/math/SafeMath.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "./constants/ConstantAddresses.sol";
//import "./aave/ILendingPool.sol";
//import "./aave/ILendingPoolAddressesProvider.sol";
//import "./aave/IAToken.sol";
//import "./interface/IAgicAddressesProvider.sol";
//import "./interface/IAgicFundPool.sol";
//
//contract AaveSavingsProtocol is ConstantAddresses, Ownable {
//
//    using SafeMath for uint256;
//
//    //load aave contract
//    ILendingPoolAddressesProvider aaveProvider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
//    ILendingPool lendingPool = ILendingPool(aaveProvider.getLendingPool());
//    IAToken aToken = IAToken(AAVE_ATOKEN_ETH);
//
//    address payable private _depositor;
//
//    IAgicAddressesProvider private _provider;
//
//    constructor(address payable depositor, address payable provider) public Ownable() {
//        _depositor = depositor;
//        _provider = IAgicAddressesProvider(provider);
//    }
//
//    function deposit() public payable onlyOwner {
//        lendingPool.deposit{value : msg.value}(AAVE_MARKET_ETH, msg.value, 0);
//    }
//
//    function balanceOf() public view onlyOwner returns (uint256){
//        return aToken.balanceOf(address(this));
//    }
//
//    function transfer(address recipient, uint256 amount) external returns (bool){
//        return aToken.transfer(recipient, amount);
//    }
//
//    function redeem(uint256 eth, uint256 serviceCharge) public onlyOwner {
//        aToken.redeem(eth);
//        uint256 addressBalance = address(this).balance;
//        require(addressBalance > 0, "Agic: not have addressBalance");
//        if (serviceCharge > 0) {
//            require(addressBalance > serviceCharge, "Agic: addressBalance < serviceCharge");
//            uint256 newBalance = addressBalance.sub(serviceCharge);
//            _depositor.transfer(newBalance);
//            IAgicFundPool(_provider.getAgicFundPool()).recordTransfer{value : address(this).balance}();
//        } else {
//            _depositor.transfer(addressBalance);
//        }
//    }
//
//    receive() external payable {}
//
//}