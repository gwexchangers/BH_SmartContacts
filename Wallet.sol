// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.7.0;

import "./Token.sol";
import "./Poll.sol";
import "./Managed.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/GSN/GSNRecipient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable, Managed, GSNRecipient {
    using SafeMath for uint256;

    Token token;

    // Designates if this wallet is able to vote
    bool public canVote;

    // Initial vested amount
    uint256 public initialVestedAmount = 0;

    // Vesting transferred
    uint256 public vestingTransferred = 0;

    // Designates the start of the vesting period
    uint256 public startVesting = 0;

    event EnableVoting();
    event ConfigureVesting(uint256 startVesting, uint256 initialVestedAmount);
    event Transfer(address to, uint256 amount);
    event Vote(address indexed poll, uint256 option);

    constructor(Token _token, address manager) public {
        token = _token;
        _manager = manager;
    }

    function enableVoting() public onlyManager {
        require(canVote == false, "Voting already enabled");

        canVote = true;

        emit EnableVoting();
    }

    function configureVesting(uint256 _initialVestedAmount) public onlyManager {
        require(initialVestedAmount == 0, "Vesting already configured");

        startVesting = block.timestamp;
        initialVestedAmount = _initialVestedAmount;

        emit ConfigureVesting(startVesting, initialVestedAmount);
    }

    function transfer(address account, uint256 amount) public onlyOwner {
        require(
            availableToTransfer() >= amount,
            "Wallet: Amount is subject to vesting or no balance"
        );
        require(
            token.transfer(account, amount),
            "Wallet: Could not complete the transfer"
        );

        if (freeFromVesting() > vestingTransferred) {
            if (amount <= freeFromVesting()) {
                vestingTransferred = vestingTransferred.add(amount);
            } else {
                vestingTransferred = freeFromVesting();
            }
        }

        emit Transfer(account, amount);
    }

    function vote(Poll poll, uint256 option) public onlyOwner {
        require(poll.vote(option), "Could not vote");

        emit Vote(address(poll), option);
    }

    function availableToTransfer() public view returns (uint256) {
        uint256 transferableVestingAmount = 0;
        uint256 calculedFreeFromVesting = freeFromVesting();

        if (calculedFreeFromVesting < vestingTransferred) {
            transferableVestingAmount = calculedFreeFromVesting;
        } else {
            transferableVestingAmount = calculedFreeFromVesting.sub(
                vestingTransferred
            );
        }

        uint256 balance = token.balanceOf(address(this));
        uint256 nonTransferrableVestingAmount = initialVestedAmount.sub(
            calculedFreeFromVesting
        );

        if (calculedFreeFromVesting != initialVestedAmount) {
            return balance.sub(nonTransferrableVestingAmount);
        } else {
            return balance;
        }
    }

    function freeFromVesting() internal view returns (uint256) {
        uint256 freeFromVesting = 0;

        if (time() >= startVesting + 270 days) {
            freeFromVesting = initialVestedAmount; // 100%
        } else if (time() >= startVesting + 180 days) {
            freeFromVesting = (initialVestedAmount * 50) / 100; // 50%
        } else if (time() >= startVesting + 90 days) {
            freeFromVesting = (initialVestedAmount * 275) / 1000; // 27.5%
        } else {
            freeFromVesting = (initialVestedAmount * 75) / 1000; // 7.5%
        }

        return freeFromVesting;
    }

    function time() public virtual view returns (uint256) {
        return block.timestamp;
    }

    function _msgSender()
        internal
        override(Context, GSNRecipient)
        view
        returns (address payable)
    {
        return GSNRecipient._msgSender();
    }

    function _msgData()
        internal
        override(Context, GSNRecipient)
        view
        returns (bytes memory)
    {
        return GSNRecipient._msgData();
    }

    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    ) external override view returns (uint256, bytes memory) {
        return _approveRelayedCall();
    }

    function _preRelayedCall(bytes memory context)
        internal
        override(GSNRecipient)
        returns (bytes32)
    {}

    function _postRelayedCall(
        bytes memory context,
        bool,
        uint256 actualCharge,
        bytes32
    ) internal override(GSNRecipient) {}
}
