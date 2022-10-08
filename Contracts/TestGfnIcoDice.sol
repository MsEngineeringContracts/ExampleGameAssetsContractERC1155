// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestGfnIcoDice is ERC1155, Ownable {

    //Owner specification
    address public contractOwner; // <-- game dev/studio wallet address
    mapping(address => uint) balance; 

    //Items definition
    uint256 public constant _Cash = 0x0;
    uint256 public constant _AssetCommon = 0x1;
    uint256 public constant _AssetRare = 0x2;
    uint256 public constant _AssetEpic = 0x3;
    uint256 public constant _AssetMyth = 0x4;
    uint256 public constant _AssetLegendary = 0x5;
    uint256 public constant _FragmentCommon = 0x6;
    uint256 public constant _FragmentRare = 0x7;
    uint256 public constant _FragmentEpic = 0x8;
    uint256 public constant _FragmentMyth = 0x9;
    uint256 public constant _FragmentLegendary = 0xa;

    uint256 private constant _InitialCashToMint = 1000;
    uint256 private constant _InitialAssetToMint = 10;
    uint256 private constant _InitialFragmentToMint = 500;

    uint256 public constant _FeePerAsset = 0.001 ether; // <-- any fees we want to change on txs
    uint256 public constant _FragmentsPerAsset = 100; // <-- any fees we want to change on txs
    uint256 public constant _CashPerAssetToBurn = 100; // <-- any fees we want to change on txs
    uint256 public constant _CashPerAssetFee = 10;

    //ModifierSection
    //Modifier -> Is limited dice token holder
    modifier mintNativeCompliance() {
        require(msg.value <= msg.sender.balance, "Insufficient balance.");
        require(msg.value >= _FeePerAsset, "Insufficient balance.");
        _;
    }

    modifier mintCashCompliance() {
        require(balanceOf(msg.sender, _Cash) >= (_CashPerAssetToBurn + _CashPerAssetFee), "Insufficient dice cash balance.");
        _;
    }

    modifier mintFragmentCompliance(uint256 _fusionRarity) {
        require(_fusionRarity >= 0, "Rarity must be >= 0 ");
        require(_fusionRarity <= 4, "Rarity must be <= 4 ");
        require(balanceOf(msg.sender, (_fusionRarity + 1) + 5) >= _FragmentsPerAsset, "Insufficient fragments.");
        _;
    }

    modifier isAsset(uint256 _id) {
        require(_id > 0, "{ID} is no asset.");
        require(_id < 6, "{ID} is no asset.");
        _;
    }

    modifier isCash(uint256 _id) {
        require(_id == 0, "{ID} is no cash.");
        _;
    }

    modifier isFragment(uint256 _id) {
        require(_id < 11, "{ID} is no fragment.");
        require(_id > 5, "{ID} is no fragment.");
        _;
    }

    //Views
    //Read status uri
    //URI update -> Owner
    string private _baseStatsURI = "https://2pe6dcechung.usemoralis.com/MetadataProtoDice_stats/";
    function setBaseStatsURI(string memory _newURI) public onlyOwner {
        _baseStatsURI = _newURI;
    }

    string private _commonURI = "stats_protodice_common.json";
    string private _rareURI = "stats_protodice_rare.json";
    string private _epicURI = "stats_protodice_epic.json";
    string private _mythURI = "stats_protodice_myth.json";
    string private _legendaryURI = "stats_protodice_legendary.json";

    function getStatsURI(uint256 _tokenRarity) public view isAsset(_tokenRarity + 1) returns(string memory){
        if(_tokenRarity == 0)
        {
            return string(abi.encodePacked(_baseStatsURI,_commonURI));
        }
        else
        if(_tokenRarity == 1)
        {
            return string(abi.encodePacked(_baseStatsURI,_rareURI));
        }
        else
        if(_tokenRarity == 2)
        {
            return string(abi.encodePacked(_baseStatsURI,_epicURI));
        }
        else
        if(_tokenRarity == 3)
        {
            return string(abi.encodePacked(_baseStatsURI,_mythURI));
        }
        else
        if(_tokenRarity == 4)
        {
            return string(abi.encodePacked(_baseStatsURI,_legendaryURI));
        }
        else{
            return string(abi.encodePacked("Error: ", "Choose rarity 0 - 4."));
        }
    }

    //Supply functions
    //Mint -> Owner
    function mintOwner(uint256 id, uint256 amount) public onlyOwner{
        _mint(contractOwner, id, amount, "");
    }

    function mintFromOwnerTo(address to, uint256 id, uint256 amount) public onlyOwner{
        _mint(to, id, amount, "");
    }

    //Mint -> User
    function mintWithCash() 
    public 
    mintCashCompliance(){
        burn(msg.sender, _Cash, _CashPerAssetToBurn);
        safeTransferFrom(msg.sender, contractOwner, _Cash, _CashPerAssetFee, "");
        uint256 randId = _createRandomNum(4) + 1;
        _mint(msg.sender, randId, 1, "");
    }

    receive() external payable{
        balance[address(this)] += msg.value;
        if(msg.value >= _FeePerAsset)
        {
            uint256 randId = _createRandomNum(4) + 1;
            _mint(msg.sender, randId, 1, "");
        }
    }

    fallback() external payable{
        balance[address(this)] += msg.value;
    }

    function mintWithNative() 
    public 
    payable 
        mintNativeCompliance(){
        (bool sent, bytes memory data) = payable(address(this)).call{value: _FeePerAsset}("Confirm to spend 0.01 ether");
        require(sent, "Failed to send Ether");
        uint256 randId = _createRandomNum(4) + 1;
        _mint(msg.sender, randId, 1, "");
    }

    function mintWithFragment(uint256 _rarity) 
    public 
    isAsset(_rarity)
    mintFragmentCompliance(_rarity){
        burn(msg.sender, (_rarity + 1) + 5, _FragmentsPerAsset);
        _mint(msg.sender, (_rarity + 1), 1, "");
    }

    //Burn -> Token holder
    function burn( address from, uint256 id, uint256 amount) public {
        require(msg.sender == from);
        _burn(from, id, amount);
    }

    //Maintenance functions
    //URI update -> Owner
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    //Read URI public
    function getUri() public view returns(IERC1155MetadataURI) {
        return IERC1155MetadataURI(this);
    }

    //Read token URI public
    function tokenURI(uint256 qId) public view returns(string memory) {
        return IERC1155MetadataURI(this).uri(qId);
    }

    //Constructor
    constructor() ERC1155("https://2pe6dcechung.usemoralis.com/MetadataProtoDice_data/{id}.json") {
        contractOwner = msg.sender;
        _mint(msg.sender, _Cash, _InitialCashToMint, "");
        _mint(msg.sender, _AssetCommon, _InitialAssetToMint, "");
        _mint(msg.sender, _AssetRare, _InitialAssetToMint, "");
        _mint(msg.sender, _AssetEpic, _InitialAssetToMint, "");
        _mint(msg.sender, _AssetMyth, _InitialAssetToMint, "");
        _mint(msg.sender, _AssetLegendary, _InitialAssetToMint, "");
        _mint(msg.sender, _FragmentCommon, _InitialFragmentToMint, "");
        _mint(msg.sender, _FragmentRare, _InitialFragmentToMint, "");
        _mint(msg.sender, _FragmentEpic, _InitialFragmentToMint, "");
        _mint(msg.sender, _FragmentMyth, _InitialFragmentToMint, "");
        _mint(msg.sender, _FragmentLegendary, _InitialFragmentToMint, "");
    }

     //Utils/helper funcs
    function _createRandomNum(uint256 _mod) internal view returns (uint256) {
        uint256 randomNum = uint256(
        keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        return randomNum % _mod;
    }

    //Withdraw -> Owner
    function withdraw() external payable onlyOwner {
        // This will transfer the remaining contract balance to the owner (contractOwner address).
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
