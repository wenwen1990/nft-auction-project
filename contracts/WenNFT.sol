// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract WenNFT is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 private _nextTokenId;
    AggregatorV3Interface internal priceETHFeed;

    mapping(address => AggregatorV3Interface) public priceFeeds;

    /// @dev 使用 initializer 代替构造函数
    function initialize(address initialOwner) public initializer {
        __ERC721_init("WenNFT", "WNFT");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function setPriceETHFeed(
        address tokenAddress,
        address _priceETHFeed
    ) public {
        require(_priceETHFeed != address(0), "Invalid price feed address");
        // priceETHFeed = AggregatorV3Interface(_priceETHFeed);
        priceFeeds[tokenAddress] = AggregatorV3Interface(_priceETHFeed);
    }
    /**
     * @dev 获取最新的 ETH 价格   ETH->USD 454693732647  4546.93732647
     * @return int256 最新的 ETH 价格  USDC->USD 99988053 0.99988053
     */
    function getLasestPrice(address tokenAddress) public view returns (int256) {
        AggregatorV3Interface priceFeed = priceFeeds[tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 price,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    /// @dev UUPS 升级授权逻辑
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /// @notice 铸造新的 NFT 给接收者
    function mint(address to) external onlyOwner {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, tokenId);
    }

    /// @notice 获取下一个将要铸造的 tokenId
    function nextTokenId() external view returns (uint256) {
        return _nextTokenId;
    }
}
