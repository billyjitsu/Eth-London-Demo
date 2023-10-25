//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

// For use with remix
// import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
// import "@openzeppelin/contracts@4.9.0/token/ERC1155/extensions/ERC1155Supply.sol";
// import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";
// import "@api3/contracts/v0.8/interfaces/IProxy.sol";
// import "@openzeppelin/contracts@4.9.0/utils/Strings.sol";

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/contracts/v0.8/interfaces/IProxy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract QrngExample is RrpRequesterV0, ERC1155Supply, Ownable {
    event RequestedUint256Array(bytes32 indexed requestId, uint256 size);
    event ReceivedUint256Array(bytes32 indexed requestId, uint256[] response);

    using Strings for uint256;

    address public airnode;
    bytes32 public endpointIdUint256Array;
    address public sponsorWallet;

    uint256[] public qrngUint256Array;

    address public proxyAddress;

    uint256 public minPaymentUSD = 20; // set our minimum price in USD

    string public GameNFT = "tokenURI string";

    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;
    //mapping to store the request id and the requester address
    mapping(bytes32 => address) public requestIdToSender;

    constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp)ERC1155(GameNFT) {}

    function setProxyAddress(address _proxyAddress) public onlyOwner {
        proxyAddress = _proxyAddress;
    }

    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256Array,
        address _sponsorWallet
    ) external {
        airnode = _airnode;
        endpointIdUint256Array = _endpointIdUint256Array;
        sponsorWallet = _sponsorWallet;
    }

    function makeRequestUint256Array(uint256 size, address _originalSender) public {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256Array,
            address(this),
            sponsorWallet,
            address(this),
            this.fulfillUint256Array.selector,
            // Using Airnode ABI to encode the parameters
            abi.encode(bytes32("1u"), bytes32("size"), size)
        );
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        // Store the original sender's address with the requestId
         requestIdToSender[requestId] = _originalSender;  
        emit RequestedUint256Array(requestId, size);
    }


    function fulfillUint256Array(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(
            expectingRequestWithIdToBeFulfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        qrngUint256Array = abi.decode(data, (uint256[]));

        require(requestIdToSender[requestId] != address(0), "requestIdToSender is empty");
        // Do what you want with `qrngUint256Array` here...

        // Loop through the entire qrngUint256Array and mint based on each value
        for (uint i = 0; i < qrngUint256Array.length; i++) {
            uint256 tokenId = qrngUint256Array[i] % 5;
            _mint(requestIdToSender[requestId], tokenId, 1, "");
        }

        emit ReceivedUint256Array(requestId, qrngUint256Array);
    }

    function readDataFeed() public view returns (uint256, uint256) {
        (int224 value, uint256 timestamp) = IProxy(proxyAddress).read();
        //convert price to UINT256
        uint256 price = uint224(value);
        return (price, timestamp);
    }
    
    function mintNFT(uint256 _amount) public payable {
    
        (uint256 price, ) = readDataFeed();

        // Convert the amount being paid (in wei) to its equivalent in USD (in wei format)
        uint256 amountInUSDWei = (msg.value * price) / 1e18;
        // Convert the USD amount in wei format to a regular USD amount
        uint256 amountInUSD = amountInUSDWei / 1e18;

        require(amountInUSD >= (minPaymentUSD * _amount) , "Amount should be more than $20 per NFT in USD value");

        makeRequestUint256Array(_amount, msg.sender);
    }

    function name() public pure returns (string memory) {
        return "The Game";
    }

    function symbol() public pure returns (string memory) {
        return "GAME";
    }  

    // URI overide for number schemes
    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(abi.encodePacked(GameNFT, Strings.toString(_tokenId), ".json"));
    }

    // Function to withdraw any remaining funds in the contract (for the owner)
    function withdraw() external onlyOwner{
        (bool success, ) = payable(msg.sender).call{value: (address(this).balance)}("");
        require(success, "Failed payout");
    }

}
