// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// @title Voting with delegation.
contract Ballot is Context {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        uint256 weight; // weight is accumulated by delegation
        bool voted; // if true, that person already voted
        address delegate; // person delegated to
        uint256 vote; // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        uint16 proposalId; // id reference (up to 16 bits)
        uint256 voteCount; // number of accumulated votes
    }

    address public chairperson;

    struct ERC1155Whitelist {
        IERC1155 address_;
        uint256 tokenId;
    }
    ERC1155Whitelist erc1155whitelist_;
    IERC721 erc721whitelist_;

    function erc1155whitelist()
        public
        view
        returns (IERC1155 addr_, uint256 tokenId)
    {
        return (erc1155whitelist_.address_, erc1155whitelist_.tokenId);
    }

    function erc721whitelist() public view returns (IERC721 addr_) {
        return erc721whitelist_;
    }

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalId`.
    constructor(
        uint16[] memory proposalIds,
        IERC1155 address1155,
        uint256 tokenId1155,
        IERC721 address721
    ) {
        chairperson = msg.sender;

        voters[chairperson].weight = 1;
        updateERC1155ToWhitelist(address1155, tokenId1155);
        updateERC721ToWhitelist(address721);

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint256 i = 0; i < proposalIds.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(
                Proposal({proposalId: proposalIds[i], voteCount: 0})
            );
        }
    }

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.

    modifier onlyChairPerson() {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        _;
    }

    function updateERC721ToWhitelist(IERC721 address_) public onlyChairPerson {
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.

        erc721whitelist_ = address_;
    }

    function updateERC1155ToWhitelist(IERC1155 address_, uint256 tokenId)
        public
        onlyChairPerson
    {
        // If the first argument of `require` evaluates
        // to `false`, execution terminates and all
        // changes to the state and to Ether balances
        // are reverted.
        // This used to consume all gas in old EVM versions, but
        // not anymore.
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.

        erc1155whitelist_ = ERC1155Whitelist(address_, tokenId);
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) external {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    event Balance(uint256 balance);

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].proposalId`.
    function vote(uint256 proposal) external {
        address caller = _msgSender();
        Voter storage sender = voters[caller];

        uint256 balance1 = erc1155whitelist_.address_.balanceOf(
            caller,
            erc1155whitelist_.tokenId
        );

        uint256 balance2 = erc721whitelist().balanceOf(caller);

        // emit Balance(balance1);
        emit Balance(balance2);

        // require(balance > 0, "Has no right to vote");
        // require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;

        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerId() external view returns (uint16 winnerId_) {
        winnerId_ = proposals[winningProposal()].proposalId;
    }
}
