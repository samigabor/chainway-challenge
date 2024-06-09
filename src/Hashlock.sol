// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Hashlock
 * @dev This contract allows locking and unlocking of 1 cBTC based on hash preimages and Merkle proofs.
 */
contract Hashlock {
    mapping(bytes32 => bool) public lockedHashes;

    event Locked(bytes32 indexed hash, address indexed sender);
    event Unlocked(bytes32 indexed hash, address indexed sender);

    /**
     * @notice Locks 1 cBTC in the contract.
     * @dev Takes a hash and locks 1 cBTC.
     * @param hash The hash to lock the funds against.
     */
    function lock(bytes32 hash) external payable {
        require(msg.value == 1 ether, "Must send exactly 1 cBTC");
        require(!lockedHashes[hash], "Hash already locked");
        lockedHashes[hash] = true;
        emit Locked(hash, msg.sender);
    }

    /**
     * @notice Unlocks 1 cBTC based on the preimage and Merkle proof.
     * @dev Takes the preimage and Merkle path to unlock the funds.
     * @param preimage The preimage of the hash.
     * @param merkleProof The Merkle proof for the hash.
     */
    function unlock(bytes32 preimage, bytes32[] calldata merkleProof) external {
        bytes32 hash = keccak256(abi.encodePacked(preimage));
        require(lockedHashes[hash], "Hash not locked");
        require(verifyMerkleProof(hash, merkleProof), "Invalid Merkle proof");
        lockedHashes[hash] = false;
        payable(msg.sender).transfer(1 ether);
        emit Unlocked(hash, msg.sender);
    }

    /**
     * @notice Verifies the Merkle proof.
     * @dev This function is used to verify the Merkle proof.
     * @param leaf The leaf node to verify.
     * @param proof The Merkle proof.
     * @return isValid Boolean indicating if the proof is valid.
     */
    function verifyMerkleProof(bytes32 leaf, bytes32[] memory proof) internal pure returns (bool) {
        // TODO: Implement Merkle proof verification logic here
        return true;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
