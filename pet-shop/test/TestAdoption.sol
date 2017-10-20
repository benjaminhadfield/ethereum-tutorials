pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Adoption.sol";

contract TestAdoption {
    Adoption adoption = Adoption(DeployedAddresses.Adoption());

    /// Test adopt() returns the given petId when successful.
    function testUserCanAdopt () {
        uint actual = adoption.adopt(7);
        uint expected = 7;
        Assert.equal(actual, expected, "Adoption of pet should return the petId.");
    }

    /// Test retrieval of a single pet's owner.
    function testGetAdopterAddressFromPetId () {
        // Expected owner is this contract.
        address expected = this;
        address actual = adoption.adopters(7);
        Assert.equal(actual, expected, "Owner of petId 7 should be recorded.");
    }

    /// Test retrieval of all pet owners.
    function testGetAllAdopters () {
        // Expect owner of 7 is this contract.
        address expected = this;
        // Get the array of owners (store in memory, not the contracts storage).
        address[16] memory adopters = adoption.getAdopters();
        Assert.equal(adopters[7], expected, "Owner of petId 7 should be recorded.");
    }
}

