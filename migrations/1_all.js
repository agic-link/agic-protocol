const Agic = artifacts.require("Agic");
const Provider = artifacts.require("AgicAddressesProvider");
const FundPool = artifacts.require("AgicFundPool");
const InterestCard = artifacts.require("AgicInterestCard");

module.exports = async function (deployer, network, accounts) {

    await deployer.deploy(Provider);
    const provider = await Provider.deployed();

    await deployer.deploy(FundPool, provider.address);
    const fundPool = await FundPool.deployed();

    await deployer.deploy(Agic, provider.address);
    const agic = await Agic.deployed();

    await deployer.deploy(InterestCard, provider.address);
    const interestCard = await InterestCard.deployed();

    await provider.addAgicFundPoolWhiteList(interestCard.address);
    await provider.setAgicFundPool(fundPool.address);
    await provider.setAgic(agic.address);
    await provider.setAgicInterestCard(interestCard.address);
}