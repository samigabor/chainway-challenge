// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import "../src/Hashlock.sol";

contract HashlockTest is Test {
    Hashlock public hashlock;
    address public user;
    bytes32 public preimage = "preimage";

    function setUp() public {
        hashlock = new Hashlock();
        user = address(0x1234);
        vm.deal(user, 1 ether);
    }

    function testLock() public {
        bytes32 hash = keccak256(abi.encodePacked(preimage));
        
        vm.prank(user);
        hashlock.lock{value: 1 ether}(hash);
        
        assertEq(address(hashlock).balance, 1 ether);
        assertTrue(hashlock.lockedHashes(hash));
    }

    function testLockAlreadyLockedHash() public {
        bytes32 hash = keccak256(abi.encodePacked(preimage));

        vm.prank(user);
        hashlock.lock{value: 1 ether}(hash);

        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectRevert("Hash already locked");
        hashlock.lock{value: 1 ether}(hash);
    }

    function testUnlock() public {
        bytes32 hash = keccak256(abi.encodePacked(preimage));
        
        vm.prank(user);
        hashlock.lock{value: 1 ether}(hash);

        bytes32[] memory merkleProof = new bytes32[](1);
        merkleProof[0] = hash;
        
        vm.prank(user);
        hashlock.unlock(preimage, merkleProof);
        
        assertEq(address(hashlock).balance, 0);
        assertFalse(hashlock.lockedHashes(hash));
        assertEq(user.balance, 1 ether);
    }

    function testUnlockInvalidPreimage() public {
        bytes32 hash = keccak256(abi.encodePacked(preimage));
        bytes32[] memory merkleProof = new bytes32[](1);
        merkleProof[0] = hash;

        vm.prank(user);
        hashlock.lock{value: 1 ether}(hash);

        vm.prank(user);
        vm.expectRevert("Hash not locked");
        hashlock.unlock("invalid", merkleProof);
    }

    // function testUnlockInvalidMerkleProof() public {
    //     bytes32 hash = keccak256(abi.encodePacked(preimage));
    //     bytes32[] memory merkleProof = new bytes32[](1);
    //     merkleProof[0] = keccak256(abi.encodePacked("invalid"));

    //     vm.prank(user);
    //     hashlock.lock{value: 1 ether}(hash);

    //     vm.prank(user);
    //     vm.expectRevert("Invalid Merkle proof");
    //     hashlock.unlock(preimage, merkleProof);
    // }
}
