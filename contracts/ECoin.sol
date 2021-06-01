// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ECoin is ERC20Burnable, Ownable {
	IERC20 public trailToken;

	constructor(
		string memory _name,
		string memory _symbol,
		address _trailToken
	) ERC20(_name, _symbol) {
		_mint(msg.sender, 1000 * (10**uint256(18)));
		trailToken = IERC20(_trailToken);
	}

	//the mint
	//bonding..
	function mint(address to, uint256 amount) public onlyOwner {
		_mint(to, amount);
	}

	// withdraw currency accidentally sent to the smart contract
	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	// reclaim accidentally sent tokens
	function reclaimToken(IERC20 token) public onlyOwner {
		require(address(token) != address(0));
		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance);
	}
}
