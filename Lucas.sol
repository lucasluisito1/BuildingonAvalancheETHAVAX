// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender; // Set the deployer as the initial owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
}

contract DegenToken is ERC20, Ownable {

    mapping(uint256 => uint256) public ShopPrices;
    mapping(address => uint256[]) public RedeemedItems;

    constructor() ERC20("Degen", "DGN") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint initial tokens to the contract deployer
        ShopPrices[1] = 100;
        ShopPrices[2] = 60;
        ShopPrices[3] = 30;
        ShopPrices[4] = 10;
    }

    function mintDGN(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function transferDGN(address _to, uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Transfer Failed: Insufficient balance.");
        _transfer(msg.sender, _to, _amount);
    }

    function showShopItems() external pure returns (string memory) {
        string memory saleOptions = "The items on sale: {1} Degen NFT (100) {2} Degen T-shirt & Hoodie (60) {3} Random IN-GAME Item (30) {4} Degen Sticker (10)";
        return saleOptions;
    }

    function redeemDGN(uint256 _item) public {
        require(ShopPrices[_item] > 0, "Item is not available.");
        require(_item <= 4, "Item is not available.");
        require(balanceOf(msg.sender) >= ShopPrices[_item], "Redeem Failed: Insufficient balance.");

        // Transfer tokens to the contract owner
        _transfer(msg.sender, owner, ShopPrices[_item]);

        // Record redeemed item for the player
        RedeemedItems[msg.sender].push(_item);

        // Emit event for redemption
        emit Redeem(msg.sender, _item);
    }
    
    function burnDGN(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Burn Failed: Insufficient balance.");
        _burn(msg.sender, _amount);
    }

    function getBalance() external view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function getRedeemedItems(address _player) external view returns (uint256[] memory) {
        return RedeemedItems[_player];
    }

    function decimals() public pure override returns (uint8) {
        return 18; // Adjust decimals as per your token requirements
    }

    event Redeem(address indexed player, uint256 item);
}
