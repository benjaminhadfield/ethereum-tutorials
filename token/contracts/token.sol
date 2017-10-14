pragma solidity ^0.4.16;

interface tokenRecipient {
    function receiveApproval (address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract TokenERC20 {
    // Public vars.
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    
    // Create a mapping of addresses to balances.
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // Events emit a public event on the blockchain that notifies clients of something.
    // More info at https://solidity.readthedocs.io/en/develop/contracts.html#events

    // Transfer event.
    event Transfer (address indexed from, address indexed to, uint256 value);
    // Burn event.
    event Burnt (address index from, uint256 value);

    /**
     * Constructor function.
     * 
     * Initialises contract with some initial supply of tokens in the creators account.
     */
    function TokenERC20 (uint initialSupply, string tokenName, string tokenSymbol) public {
        // Update totalSupply with the decimal amount.
        totalSupply = initialSupply * 10 ** uint256(decimals);
        // Give the creator all initial tokens.
        balanceOf[msg.sender] = totalSupply;
        // Set the token name and symbol.
        name = tokenName;
        symbol = tokenSymbol;
    }

    /**
     * Internal transfer, only called by this contract.
     */
    function _transfer (address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead.
        require(_to != 0x0);
        // Check sender has enough tokens to make transfer.
        require(balanceOf[_from] >= _value);
        // Check overflows.
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save current balances for later assertion.
        uint prevBalanceTotal = balanceOf[_from] + balanceOf[_to];
        // Make transfer, (1) subtract from sender. (2) add to receiver.
        balanceOf[_from] -= _value;  // (1)
        balanceOf[_to] += _value  // (2)
        // Send Transfer event.
        Transfer(_from, _to, _value);
        // Assert that the total number of tokens before and after the transfer is equal.
        assert(balanceOf[_from] + balanceOf[_to] == prevBalanceTotal);
    }

    /**
     * Transfer tokens.
     *
     * Send `_value` tokens to `_to` from sender's account.
     * @param _to The recepient's address.
     * @param _value The amount to send.
     */
    function transfer (address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
    }
}

