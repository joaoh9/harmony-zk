// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract E1155 is ERC1155, Ownable {
    uint256 public constant GOVERNANCE = 1;

    constructor(string memory tokenURI_) ERC1155(tokenURI_) {
        _mint(msg.sender, GOVERNANCE, 10000, "");
    }

    function changeURI(string memory tokenURI_) public onlyOwner {
        _setURI(tokenURI_);
    }

    function mintMore(uint256 newNFTs) public onlyOwner {
        _mint(msg.sender, GOVERNANCE, newNFTs, "");
    }

    function burn(uint256 burnAmount) public onlyOwner {
        _burn(msg.sender, GOVERNANCE, burnAmount);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    uri(tokenId),
                    Strings.toString(tokenId),
                    ".json"
                )
            )
        );
    }
}
