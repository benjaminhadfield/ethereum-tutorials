pragma solidity ^0.4.4;

contract Adoption {
    address[16] public adopters;

    /**
     * Get the array of all adopters, since the provided getter only
     * returns a single value.
     */
    function getAdopters() public returns (address[16]) {
        return adopters;
    }

    /**
     * Adopts a specified pet.
     */
    function adopt (uint petId) public returns (uint) {
        // Check the petId is valid.
        require(petId >= 0 && petId < 16);
        // Set the specified sender as the adopter.
        adopters[petId] = msg.sender;
        return petId;
    }
}
