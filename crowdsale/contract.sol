pragma solidity ^0.4.4;

interface token {
  function transfer (address receiver, uint amount);
}

contract Crowdsale {
  address public beneficiary;
  uint public goal;
  uint public amountRaised;
  uint public deadline;
  uint public price;
  token public tokenReward;
  mapping (address => uint256) public balanceOf;
  bool fundingGoalReached = false;
  bool closed = false;

  event GoalReached (address owner, uint value);
  event FundTransfer (address backer, uint amount, bool isContribution);

  /**
   * Contructor.
   */
  function Crowdsale (
     address ifSuccessfulSendTo,
     uint fundingGoalInEthers,
     uint durationInMinutes,
     uint etherCostOfEachToken,
     address addressOfTokenUsedAsReward
  ) {
    beneficiary = ifSuccessfulSendTo;
    goal = fundingGoalInEthers * 1 ether;
    deadline = now + durationInMinutes * 1 minutes;
    price = etherCostOfEachToken * 1 ether;
    tokenReward = token(addressOfTokenUsedAsReward);
  }

  /**
   * Fallback Function.
   *
   * This function is the default function called whenever funds are sent to this contract.
   */
  function () payable {
    require(!closed);
    uint amountSent = msg.value;
    balanceOf[msg.sender] = amountSent;
    amountRaised += amountSent;
    tokenReward.transfer(msg.sender, amountSent / price);
    FundTransfer(msg.sender, amountSent, true);
  }

  modifier afterDeadline () {
    if (now >= deadline) {
      _;
    }
  }

  /**
   * Check if goal was reached.
   *
   * Checks if the goal or timelimit has been reached and ends the crowdsale.
   */
  function checkGoalReached () afterDeadline {
    if (amountRaised >= goal) {
      fundingGoalReached = true;
      GoalReached(beneficiary, amountRaised);
    }
    closed = true;
  }

  /**
   * Withdraw the funds.
   *
   * Checks to see if the goal or timelimit has been met, and if so, and the goal
   * has been reached, send the entire amount to the beneficiary. If goal not reached
   * refund all contributors.
   */
  function withdraw () afterDeadline {
    if (!fundingGoalReached) {
      uint amount = balanceOf[msg.sender];
      balanceOf[msg.sender] = 0;
      if (amount > 0) {
        if (msg.sender.send(amount)) {
          FundTransfer(msg.sender, amount, false);
        } else {
          balanceOf[msg.sender] = amount;
        }
      }
    }

    if (fundingGoalReached && beneficiary == msg.sender) {
      if (beneficiary.send(amountRaised)) {
        FundTransfer(beneficiary, amountRaised, false);
      } else {
        // If there is a failure in sending funds to owner, then we unlock funds
        // for contributors.
        fundingGoalReached = false;
      }
    }
  }
}
