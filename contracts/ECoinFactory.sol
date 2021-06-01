// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ECoin.sol";

contract ECoinFactory is Ownable {
	event NewToken(string name, string symbol);

	struct Token {
		address contractAddress;
		string name;
		string symbol;
		address trailToken;
		uint256 createdAt;
	}

	Token[] public tokens;
	uint256 private numTokens = 0;

	mapping(uint256 => address) public tokenToOwner;

	function createToken(
		string memory _name,
		string memory _symbol,
		address _trailToken
	) public onlyOwner returns (address) {
		address ecoin = address(new ECoin(_name, _symbol, _trailToken));
		Token memory token = Token(ecoin, _name, _symbol, _trailToken, block.timestamp);
		tokens.push(token);
		numTokens++;
		tokenToOwner[numTokens] = msg.sender;
		emit NewToken(_name, _symbol);
		return ecoin;
	}

	function getTokenAddressByIndex(uint256 _index) public view returns (address) {
		return tokens[_index].contractAddress;
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
