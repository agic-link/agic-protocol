// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IAgicAddressesProvider.sol";
import "./interface/IAgicFundPool.sol";
import "./interface/IWETH.sol";
import "./constants/ConstantAddresses.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";
import "./aave/IAToken.sol";

contract Agic is ConstantAddresses, ERC20, Ownable {

    using SafeMath for uint256;

    uint256 private _totalPledgeEth;

    mapping(address => uint256) private _pledgeEth;

    IAgicAddressesProvider public immutable _provider;

    ILendingPoolAddressesProvider public immutable _aaveProvider;

    IAToken public immutable _aWETH;

    IWETH public immutable _WETH;

    constructor (address agicAddressesProvider) ERC20("Automatically Generate Of Interest Coin", "AGIC") Ownable(){
        _provider = IAgicAddressesProvider(agicAddressesProvider);
        _aWETH = IAToken(AAVE_ATOKEN_WETH);
        _aaveProvider = ILendingPoolAddressesProvider(AAVE_LENDING_POOL_ADDRESSES_PROVIDER);
        _WETH = IWETH(WETH);
    }

    modifier notZeroAddress(address _to) {
        require(_to != address(0), "Agic: transfer from the zero address");
        _;
    }

    function getTotalPledgeEth() public view returns (uint256){
        return _totalPledgeEth;
    }

    function getPledgeEth(address owner) public view notZeroAddress(owner) returns (uint256){
        return _pledgeEth[owner];
    }

    function totalWETHBalanceOf() public view returns (uint256 totalBalanceOf){
        totalBalanceOf = _aWETH.balanceOf(address(this));
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        return _ethBalanceOf(owner).mul(4);
    }

    function _transfer(address from, address to, uint256 amount) internal override(ERC20) {
        require(amount > 0, "Agic: Transferred amount needs to be greater than zero");
        uint256 balance = balanceOf(from);
        require(balance > amount, "Agic: transfer amount exceeds balance");

        (uint256 subPledgeEth,,) = _rewardAmount(amount);

        _pledgeEth[from] = _pledgeEth[from].sub(subPledgeEth);
        _pledgeEth[to] = _pledgeEth[to].add(subPledgeEth);

        super._transfer(from, to, amount);
    }

    //Pledge eth in exchange for AGIC
    function deposit() public payable {
        uint256 eth = msg.value;
        uint256 agic = eth.mul(4);

        _totalPledgeEth = _totalPledgeEth.add(eth);
        _pledgeEth[msg.sender] = _pledgeEth[msg.sender].add(eth);
        super._mint(msg.sender, agic);

        _WETH.deposit{value : eth}();
        address pool = _aaveProvider.getLendingPool();
        _safeApprove(WETH, pool, 0);
        _safeApprove(WETH, pool, eth);

        ILendingPool(pool).deposit(WETH, eth, address(this), 0);
        emit Deposit(eth, agic, msg.sender);
    }

    function withdraw(uint256 agic) public {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= agic, "Agic: Not so much balance");

        uint256 withdrawEth = agic.div(4);
        (uint256 subPledge,, uint256 fee) = _rewardAmount(withdrawEth);

        uint256 userPledgeEth = _pledgeEth[msg.sender];
        require(userPledgeEth >= subPledge, "Agic: Not so much subPledgeEth");

        _pledgeEth[msg.sender] = userPledgeEth.sub(subPledge);
        _totalPledgeEth = _totalPledgeEth.sub(subPledge);
        uint256 subAgic = subPledge.mul(4);
        _burn(msg.sender, subAgic);

        uint256 totalWithdrawEth = withdrawEth.add(fee);
        address pool = _aaveProvider.getLendingPool();

        _safeApprove(WETH, pool, 0);
        _safeApprove(WETH, pool, totalWithdrawEth);
        ILendingPool(pool).withdraw(WETH, totalWithdrawEth, address(this));
        _WETH.withdraw(totalWithdrawEth);

        _safeTransferETH(msg.sender, withdrawEth);
        IAgicFundPool(_provider.getAgicFundPool()).recordTransfer{value : fee}();

        emit Withdraw(subPledge, subAgic, msg.sender);
    }

    /**
     * @dev Calculate reward and fee based on the withdrawal amount
     * @return subPledge Reduced amount of pledged eth, reward, Platform revenue
     */
    function _rewardAmount(uint256 amount) internal view returns (uint256 subPledge, uint256 reward, uint256 fee){
        uint256 totalBalanceOf = _aWETH.balanceOf(address(this));
        uint256 supply;
        {
            uint256 numerator = amount.mul(_totalPledgeEth);
            subPledge = numerator.div(totalBalanceOf);
            supply = amount.sub(subPledge);
        }
        reward = supply.mul(95).div(100);
        fee = supply.sub(reward);
    }

    //pledge + reward
    function _ethBalanceOf(address owner) internal view notZeroAddress(owner) returns (uint256 userBalanceOf){
        uint256 totalBalanceOf = _aWETH.balanceOf(address(this));
        uint256 pledgeEth = _pledgeEth[owner];
        uint256 supply;
        {
            uint256 totalPledgeEth = _totalPledgeEth;
            uint256 numerator = pledgeEth.mul(totalBalanceOf);
            uint256 balance = numerator.div(totalPledgeEth);
            supply = balance.sub(pledgeEth).mul(95).div(100);
        }
        userBalanceOf = supply.add(pledgeEth);
    }

    function _safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'Agic: ETH_TRANSFER_FAILED');
    }

    function _safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)'))) = 0x095ea7b3;
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Agic: APPROVE_FAILED');
    }

    receive() external payable {
        assert(msg.sender == WETH);
        // only accept ETH via fallback from the WETH contract
    }

    event Deposit(uint256 _value, uint256 _agic, address _sender);

    event Withdraw(uint256 _value, uint256 _agic, address _sender);

}
