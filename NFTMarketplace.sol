// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
* NFT Marketplace Smart Contract
* This contract allows us to create our own NFT Marketplace where we can buy and sell ERC-721 NFTs.
* The dependencies that our contract inherits from Oppen Zepelin are:
* - The ERC-721 interface dependency
* - The ERC-20 interface dependency 
* - The counters dependency: SC that allows us to implement accounting functions (increase/decrement a counter, get the current value of the counter,...)
* - The Ownable dependency: SC that allows us to differentiate the owner of the contract
*/
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketPlace is Ownable {
    
    // State variables
    IERC20 token; 
    IERC721 NFTs;

    // An enum that shows us the state of a sale
    enum Status {
        open,
        cancelled,
        executed
    }
    
    // An struct of a sale
    struct Sale {
        address owner;
        uint256 nftID;
        uint256 price;
        Status status;
    }
    
    // Mapping for tracking the sales and NFTsID
    mapping(uint256 => Sale) public sales;
    // Mapping for tracking the NFTsID
    mapping(uint256 => uint256) refNFTs;
    // Mapping for ensuring that in the same block only one operation has been done with a specific NFT
    mapping(uint256 => uint256) security;

    using Counters for Counters.Counter;
    Counters.Counter counter;

    modifier securityFrontRunning(uint256 _nftID) {
        require(
            security[_nftID] == 0 ||
            security[_nftID] < block.number,
            "Error security"
        );

        security[_nftID] = block.number;

        _;
    }

    constructor (address _stableCoinUsdContract, address _nftsContract) {
        token = IERC20(_stableCoinUsdContract);
        NFTs = IERC721(_nftsContract);
    }

    function openSale(uint256 _nftID, uint256 _price) public securityFrontRunning(_nftID) {
        if (refNFTs[_nftID] == 0) {
            NFTs.transferFrom(msg.sender, address(this), _nftID);

            counter.increment();
            sales[counter.current()] = Sale(
                msg.sender,
                _nftID,
                _price,
                Status.open
            );

            refNFTs[_nftID] = counter.current();
        } else {
            uint256 pos = refNFTs[_nftID];

            require(
                msg.sender == sales[pos].owner,
                "Without permission"
            );

            NFTs.transferFrom(msg.sender, address(this), _nftID);

            sales[pos].status = Status.open;
            sales[pos].price = _price;
        }
    }

    function cancelSale(uint256 _nftID) public securityFrontRunning(_nftID) {
        uint256 pos = refNFTs[_nftID];

        require(
            msg.sender == sales[pos].owner,
            "Without permission"
        );

        require(sales[pos].status == Status.open, "Is not Open");

        sales[pos].status = Status.cancelled;

        NFTs.transferFrom(address(this), sales[pos].owner, _nftID);
    }

    function buy(uint256 _nftID, uint256 _price) public  securityFrontRunning(_nftID) {
        uint256 pos = refNFTs[_nftID];

        require(sales[pos].status == Status.open, "Is not Open");

        address oldOwner = sales[pos].owner;
        uint256 price = sales[pos].price;
        
        require(price == _price, "Manipulated price");

        sales[pos].owner = msg.sender;
        sales[pos].status = Status.executed;

        require(token.transferFrom(msg.sender, oldOwner, price), "Error transfer token - price");
        require(token.transferFrom(msg.sender, address(this), (price / 100) * 5), "Error transfer fee"); // fee 5%

        NFTs.transferFrom(address(this), msg.sender, _nftID);
    }

    function getFees() public onlyOwner {
        require(
            token.transfer(msg.sender, token.balanceOf(address(this))),
            "Error transfer total fees"
        );
    }
}