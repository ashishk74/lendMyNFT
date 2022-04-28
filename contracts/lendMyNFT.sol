//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
contract Owner {
    address private owner;
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    function getOwner() external view returns (address) {
        return owner;
    }
}
contract LendMyNFT is Owner{

    IERC721 public nft;
    IERC20 usdc;

    constructor () {
        
    }
    uint8 interest;    
    uint256 loanId;
    uint256 lastCheckedId;
    mapping (uint256 => Collateral) stake;  // tokenid to Collateral
    mapping (uint256 => Loan) loans;    // loanId to Loan
    mapping(uint256 => bool) npa;   // loanId to overdue status
    struct Collateral {

        uint256 price ; // in wei

    }
    struct Loan {
        uint32 startTime;
        uint32 endTime;
        uint8 rate; // per annum
        uint256 principal;
        uint256 tokenId;
        
    }
    function setInterestRate(uint8 _rate) public isOwner {
        interest = _rate;
    }
    function viewInterestRate() public view returns(uint8){
        return interest;
    }

    function borrow (uint256 _tokenId, uint32 _endTime) public returns(uint256 LoanId) {
        uint256 weiAmount = stake[_tokenId].price *70/100;
        nft.safeTransferFrom(msg.sender,address(this),_tokenId);
        usdc.transfer(msg.sender,weiAmount);
        loanId++;
        loans[loanId] = Loan(uint32(block.timestamp),_endTime,interest,weiAmount,_tokenId);
        npa[loanId] = false;
        return loanId;
    }
    function rePay(uint256 _loanId) public {
        require(block.timestamp<loans[_loanId].endTime, "Error: Repay time expired");
        uint32 elapsedTime = uint32(block.timestamp) - loans[_loanId].startTime;
        uint256 rePayAmount = loans[_loanId].principal*(1 + loans[_loanId].rate * elapsedTime/(60*60*24*365*100));
        usdc.transfer(address(this), rePayAmount);
        nft.safeTransferFrom(address(this), msg.sender, loans[_loanId].tokenId);
    }
    function assignNPA() public {
        
        for(uint256 i = lastCheckedId; i<=loanId;i++){
            if(loans[i].endTime<block.timestamp){
                npa[i] = true;
            }
        }
        lastCheckedId = loanId;
    }
    function listNPA(uint256 j) public view returns(uint256[] memory){
        uint k;
        uint256[] memory npas = new uint256[](j);
        for(uint i=0;i<=loanId;i++){
            if(k<=j){
                if(npa[i] == true){
                npas[k] = i;
                k++;
                }
            }
            
        }
        return npas;
    }

}