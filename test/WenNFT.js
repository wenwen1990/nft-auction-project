const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("WenNFT", function () {
    let WenNFT, wenNft, owner, addr1;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();
        WenNFT = await ethers.getContractFactory("WenNFT");
        wenNft = await upgrades.deployProxy(WenNFT, [owner.address], {
            initializer: "initialize",
            kind: "uups",
        });
        await wenNft.waitForDeployment();
    });

    it("should set and get latest price", async function () {
        // 部署 Mock Aggregator
        const MockV3Aggregator = await ethers.getContractFactory("MockV3Aggregator");
        const mockAggregator = await MockV3Aggregator.deploy(8, 1000_00000000); // 价格 10.0 USD，8位精度
        await mockAggregator.deployed();

        // 设置价格预言机
        await wenNft.setPriceETHFeed(addr1.address, mockAggregator.address);

        // 获取最新价格
        const price = await wenNft.getLasestPrice(addr1.address);
        expect(price).to.equal(1000_00000000);
    });
});
