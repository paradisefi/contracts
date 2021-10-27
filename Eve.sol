pragma solidity ^0.8.0;

import "../contracts/utils/math/SafeMath.sol";
import "../contracts/access/Ownable.sol";
import "../contracts/security/Pausable.sol";
import "../contracts/utils/Address.sol";
import "../contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../contracts/utils/Counters.sol";
import "./IBEP20.sol";
import "./Auth.sol";

contract Bunny is ERC721Enumerable, Pausable, Auth {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    string private _baseUri;
	string private _fileExtension;

    Counters.Counter tokenCounter;

    uint256 private subMint;
    uint256 private wholeMint;
    uint256 private MAX_SUPPLY = 11111;
    
    IBEP20 subToken;    
    
    address private fundAddress;

    constructor(address contractToken) ERC721("Eve Bunnies", "Bunny") Auth(msg.sender) {
      subMint = 111 ether;
      wholeMint = 222 ether;
      subToken = IBEP20(contractToken);
      fundAddress = msg.sender;
    }

    function setSubMint(uint256 amount) external authorized {
        subMint = amount;
    }
    
    function setWholeMint(uint256 amount) external authorized {
        wholeMint = amount;
    }

    function getCurrentTokenCount() external view returns (uint256) {
        return tokenCounter.current();
    }

    function setBaseUri(string memory uri) public authorized {
        _baseUri = uri;
    }

	function setFileExtension(string memory ext) public authorized {
        _fileExtension = ext;
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_baseUri, uint2str(tokenId), _fileExtension));
    }
    
    function mintNFTsSub(uint256 numberOfNfts, uint256 amount) external payable {
        uint256 totalCost = numberOfNfts * subMint;
        require(msg.value == totalCost, "Not enough ONE");
        require(tokenCounter.current() < MAX_SUPPLY, "Supply Minted");
        payable(fundAddress).transfer(msg.value);
        subToken.transferFrom(msg.sender, address(0), 1111 * numberOfNfts * 1 ether);
        
        for(uint i = 0; i <numberOfNfts; i++) {
            tokenCounter.increment();
            uint256 _tokenId = tokenCounter.current();
            require(_tokenId <= MAX_SUPPLY, "Supply minted");
            _safeMint(msg.sender, _tokenId);
            
        }
    }
    
    function mintNFTsWhole(uint256 numberOfNfts) external payable {
        uint256 totalCost = numberOfNfts * wholeMint;
        require(msg.value == totalCost, "Not enough ONE");
        require(tokenCounter.current() < MAX_SUPPLY, "Supply Minted");
        
        for(uint i = 0; i <numberOfNfts; i++) {
            tokenCounter.increment();
            uint256 _tokenId = tokenCounter.current();
            require(_tokenId <= MAX_SUPPLY, "Supply minted");
            _safeMint(msg.sender, _tokenId);
            
        }
    }


    function resuce() external authorized {
        uint256 totalBalance = address(this).balance;
        payable(msg.sender).transfer(totalBalance);
    }

}
