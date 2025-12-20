// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTMarketplace {
    // NFT结构体
    struct NFT {
        uint256 id;
        address owner;
        uint256 price;
        bool forSale;
    }

    // 存储所有NFT
    NFT[] public nfts;
    // 映射：地址 => 拥有的NFT ID列表
    mapping(address => uint256[]) public ownedNFTs;

    // 事件
    event NFTCreated(uint256 id, address owner);
    event NFTListed(uint256 id, uint256 price);
    event NFTSold(uint256 id, address buyer, uint256 price);

    // 铸造NFT
    function mintNFT() public {
        uint256 newId = nfts.length;
        nfts.push(
            NFT({id: newId, owner: msg.sender, price: 0, forSale: false})
        );
        ownedNFTs[msg.sender].push(newId);
        emit NFTCreated(newId, msg.sender);
    }

    // 上架NFT
    function listNFT(uint256 _id, uint256 _price) public {
        require(_price > 0, "Price must be greater than 0");
        require(nfts[_id].owner == msg.sender, "Not the owner");
        nfts[_id].price = _price;
        nfts[_id].forSale = true;
        emit NFTListed(_id, _price);
    }

    // 下架NFT
    function delistNFT(uint256 _id) public {
        require(nfts[_id].owner == msg.sender, "Not the owner");
        nfts[_id].forSale = false;
    }

    // 购买NFT
    function buyNFT(uint256 _id) public payable {
        NFT storage nft = nfts[_id];
        require(nft.forSale, "NFT not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address payable oldOwner = payable(nft.owner);
        nft.owner = msg.sender;
        nft.forSale = false;

        // 更新映射（同上）
        for (uint i = 0; i < ownedNFTs[oldOwner].length; i++) {
            if (ownedNFTs[oldOwner][i] == _id) {
                ownedNFTs[oldOwner][i] = ownedNFTs[oldOwner][
                    ownedNFTs[oldOwner].length - 1
                ];
                ownedNFTs[oldOwner].pop();
                break;
            }
        }
        ownedNFTs[msg.sender].push(_id);

        // 替换 transfer 为 call{value: ...}
        (bool success, ) = oldOwner.call{value: msg.value}("");
        require(success, "Failed to send Ether");

        emit NFTSold(_id, msg.sender, nft.price);
    }

    // 查询所有在售NFT
    function getListedNFTs() public view returns (NFT[] memory) {
        uint256 count = 0;
        for (uint i = 0; i < nfts.length; i++) {
            if (nfts[i].forSale) count++;
        }

        NFT[] memory listed = new NFT[](count);
        uint256 index = 0;
        for (uint i = 0; i < nfts.length; i++) {
            if (nfts[i].forSale) {
                listed[index] = nfts[i];
                index++;
            }
        }
        return listed;
    }
}
