// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "./Token.sol";
import "./Wallet.sol";
import "./WalletRegistry.sol";
import "./Managed.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Poll is Ownable, Managed {
    WalletRegistry walletRegistry;
    Token token;

    // Designates when the poll is over
    uint256 end;

    string question;

    struct Option {
        uint256 id;
        string text;
        uint256 votes; // Represented in weis
    }

    Option[] options;

    mapping(address => bool) private voted;

    modifier canVote() {
        Wallet wallet = Wallet(_msgSender());
        require(wallet.canVote(), "This wallet cannot vote");
        require(token.balanceOf(address(wallet)) > 0, "No balance to vote");
        require(
            walletRegistry.exists(_msgSender()),
            "Sender is not a registered contract"
        );
        require(!voted[address(wallet)], "Wallet already voted");
        require(end < now, "Voting period is already over");
        _;
    }

    constructor(
        WalletRegistry _walletRegistry,
        Token _token,
        string memory _question
    ) public {
        walletRegistry = _walletRegistry;
        token = _token;
        question = _question;
    }

    function addOption(uint256 optionId, string memory text)
        public
        onlyManager
    {
        options.push(Option(optionId, text, 0));
    }

    function vote(uint256 optionId) public canVote returns (bool) {
        for (uint256 index = 0; index < options.length; index++) {
            if (options[index].id == optionId) {
                options[index].votes += token.balanceOf(_msgSender());
                voted[_msgSender()] = true;
                return true;
            }
        }

        revert("Not a valid option");
    }

    function optionText(uint256 index) public view returns (string memory) {
        return options[index].text;
    }

    function optionVotes(uint256 index) public view returns (uint256) {
        return options[index].votes;
    }
}
