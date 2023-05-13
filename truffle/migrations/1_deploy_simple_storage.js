const UserContract = artifacts.require("UserContract");
const CampaignContract = artifacts.require("CampaignContract");
const Crowdfund = artifacts.require("Crowdfund");

module.exports = async function (deployer) {
  await deployer.deploy(UserContract);
  const user = await UserContract.deployed();

  const oneDay = 24 * 60 * 60;
  const maxDuration = 10 * oneDay;
  await deployer.deploy(CampaignContract, user.address, maxDuration);
  const campaign = await CampaignContract.deployed();

  const tokens= ['0xc340C1763Dda3a2c1a402fD2654115d1BE406a8A', '0xaeA0870E24Ce54C97E924de6E5587f53Faf26d3E'];

  await deployer.deploy(Crowdfund, campaign.address, tokens);
};
