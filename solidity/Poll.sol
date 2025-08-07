// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {HonkVerifier} from "../circuits/target/circuits.sol";

contract Poll {
    HonkVerifier public immutable verifier;

    uint256 public value;

    constructor(address verifierAddress) {
        verifier = HonkVerifier(verifierAddress);
    }

    function updateValue(bytes calldata proof, uint256 stateRoot) public {
        verifyPollJoined(proof, stateRoot);

        value += 1;
    }

    function verifyPollJoined(
        bytes calldata proof,
        uint256 stateRoot
    ) public view returns (bool) {
        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = bytes32(stateRoot);

        return verifier.verify(proof, publicInputs);
    }
}
