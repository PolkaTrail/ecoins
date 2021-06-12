pragma solidity 0.8.4;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract
contract BondingCurve {

    IERC20 public token;
    uint public soldAmount;

    event Bought(address indexed account, uint amount, uint ethAmount);
    event Sold(address indexed account, uint amount, uint ethAmount);

    constructor(IERC20 _token)  {
        token = _token;
    }

    function buy(uint tokenAmount) external payable {
        uint nextSold = soldAmount + tokenAmount;
        uint ethAmount = s(soldAmount, nextSold);
        soldAmount = nextSold;
        require(msg.value >= ethAmount, "value is too small");
        token.transfer(msg.sender, tokenAmount);
        if (msg.value > ethAmount)
            payable(msg.sender).transfer(msg.value - ethAmount);
        emit Bought(msg.sender, tokenAmount, ethAmount);
    }

    function sell(uint tokenAmount) external {
        uint nextSold = soldAmount - tokenAmount;
        uint ethAmount = s(nextSold, soldAmount);



        soldAmount = nextSold;
        token.transfer(msg.sender, tokenAmount);

        
        emit Sold(msg.sender, tokenAmount, ethAmount);
    }

    function s(uint x0, uint x1) public view virtual returns (uint);
}
