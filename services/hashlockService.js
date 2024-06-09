const { ethers } = require("ethers");
const axios = require("axios");
const crypto = require("crypto");

const { exec } = require('child_process');

const citreaRpc = "https://rpc.devnet.citrea.xyz";
const celestiaRpc = "https://celestia-rpc.publicnode.com/";
const citreaAddress = "0xB9c2b34526fDc1Fe585eA4717acD7a91D760D28D"; // citrea address holding cBTC
const hashlockContractAddress = "0x18C7a691d690D04b4605987999c85855de0cE9Bc"; // Hashlock contract address deployed on citrea

const providerCitrea = new ethers.providers.JsonRpcProvider(citreaRpc);
const providerCelestia = new ethers.providers.JsonRpcProvider(celestiaRpc);

const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, providerCitrea);
const hashlockAbi = [
    // ABI of the Hashlock contract
    "function lock(bytes32 hash) external",
    "function unlock(bytes32 preimage, bytes32[] calldata merkleProof) external"
];
const hashlockContract = new ethers.Contract(hashlockContractAddress, hashlockAbi, wallet);

var blockHeight;


async function main() {
    while (true) {
        // Generate a random preimage
        const preimage = crypto.randomBytes(32).toString('hex');
        const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(preimage));
        console.log("Preimage hash:", hash);

        // Send the hash to Celestia as a blob
        await sendHashToCelestia(hash);

        // Wait for the blob to be included in a Celestia block
        await waitForInclusionInCelestia(hash);
        console.log("Block height: ", blockHeight);

        // Deploy the BlobstreamX contract on Citrea with the Celestia block height
        await deployBlobstreamX(blockHeight);

        // Get the Merkle path of your hash blob from Celestia
        const merklePath = await getMerklePathFromCelestia(hash);

        // Call the lock function of the hashlock smart contract with the hash
        await lockHash(hash);

        // Call the unlock function of the hashlock smart contract with the preimage and the Merkle path
        await unlockHash(preimage, merklePath);

        // Wait for some time before next iteration
        await new Promise(resolve => setTimeout(resolve, 60000)); // Wait for 1 minute
    }
}

async function sendHashToCelestia(hash) {
    var request = `curl -H "Content-Type: application/json" -H "Authorization: Bearer $CELESTIA_NODE_AUTH_TOKEN" -X POST --data '{"id": 1,
        "jsonrpc": "2.0",
        "method": "blob.Submit",
        "params": [
            [
                {
                    "namespace": "AAAAAAAAAAAAAAAAAAAAAAAAAAECAwQFBgcICRA=",
                    "data": "` + `${hash.slice(2)}` + `",
                    "share_version": 0,
                    "commitment": "AD5EzbG0/EMvpw0p8NIjMVnoCP4Bv6K+V6gjmwdXUKU="
                }
            ],
            0.002
        ]
    }' 127.0.0.1:26658`;

    exec(request, (error, stdout, stderr) => {
        blockHeight = JSON.parse(stdout).result;
        // console.log({ error, stdout, stderr })
    });
}

async function waitForInclusionInCelestia(hash) {
    await new Promise(resolve => setTimeout(resolve, 15000)); // Wait for 15 sec (Celestia block time is 12 sec)
    // TODO: remove fixed wait time and implement a polling mechanism to check if the hash is included in a Celestia block
}

async function deployBlobstreamX(blockHeight) {
    console.log(`Deploying BlobstreamX contract with block height: ${blockHeight}`);
    // TODO: unable to deploy blobstreamX contract due to the missing GATEWAY_ADDRESS address
    // GATEWAY_ADDRESS can be obtained by ceploying SuccinctGateway contract for which the documentation is incomplete
}

async function getMerklePathFromCelestia(hash) {
    console.log(`Getting Merkle path for hash: ${hash}`);
    // TODO
}

async function lockHash(hash) {
    const tx = await hashlockContract.lock(hash);
    await tx.wait();
    console.log(`Locked hash: ${hash}`);
}

async function unlockHash(preimage, merklePath) {
    const tx = await hashlockContract.unlock(preimage, merklePath);
    await tx.wait();
    console.log(`Unlocked hash with preimage: ${preimage}`);
}

main().catch(console.error);
