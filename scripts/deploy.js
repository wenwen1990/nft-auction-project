const { ethers, upgrades } = require("hardhat");

async function main() {
  const WenNFT = await ethers.getContractFactory("WenNFT");
  console.log("正在部署 WenNFT Proxy...");

  const signer = (await ethers.getSigners())[0];
  const wenNft = await upgrades.deployProxy(WenNFT, [signer.address], {
    initializer: "initialize",
    kind: "uups",
  });

  await wenNft.waitForDeployment();
  console.log("WenNFT Proxy 部署成功:", await wenNft.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
