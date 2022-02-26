// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract E721 is ERC721, Ownable {
    uint256 public constant GOVERNANCE = 1;

    constructor() ERC721("Nome", "symbol") {
        _mint(msg.sender, 1);
    }

    function mintMore() public onlyOwner {
        _mint(msg.sender, 1);
    }

    function burn() public onlyOwner {
        _burn(1);
    }
}
