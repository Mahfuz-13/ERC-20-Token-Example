// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract MyToken  {

    string public  name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply; 
    address public owner;
    bool public paused = false;


    mapping(address => bool) private frozenAccounts;
    mapping(address => uint256) private balances;
   mapping(address => mapping(address => uint256)) private allowances;
   mapping(address => bool) private blacklistedAccounts;
    
    modifier onlyOwner() {
    require(msg.sender == owner,"Only the owner can call this fucntion");
    _;
    }
    modifier whenNotPaused() {
    require(!paused,"All token transfering is paused for the moment");
    _;
    }
    modifier notFrozen(address account) {
    require(!frozenAccounts[account],"This account is frozen for this moment");
    _;
    }
    modifier notBalckListed(address account) {
    require(!blacklistedAccounts[account],"This account is blackListed for this moment");
    _;
    }

    event Transfer (address indexed from,address indexed to,uint256 value);
    event Approval (address indexed owner,address indexed spender,uint256 value);
    event Frozen (address indexed account);
    event UnFrozen (address indexed account);
    event Blacklisted (address indexed account);
    event UnBlackListed (address indexed account);
    event Ownertransferrd (address indexed previousOwner,address indexed newOwner);
    event Paused();
    event Unpaused();

    


     constructor()  {
        owner = msg.sender;
        totalSupply = 1000000 * (10 ** uint256(decimals));
        balances[owner]=totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }


    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
   

      function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0),"Cannot mint to this account");
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function burn (uint256 amount ) external whenNotPaused notBalckListed(msg.sender) notFrozen(msg.sender){
       require(balances[msg.sender] >= amount, "Insufficient balance to burn");
       totalSupply -= amount;
       balances[msg.sender] -= amount;

    }
    
    function freezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = true;
        emit Frozen(account);
    }

    function unfreezeAccount(address account) public onlyOwner {
        frozenAccounts[account] = false;
        emit UnFrozen(account);
    }
    
     function transferOwner (address newOwner)  onlyOwner public  {
        owner = newOwner;
        emit Ownertransferrd(msg.sender, newOwner);
    }


  function transfer(address to, uint256 value) public payable  whenNotPaused notBalckListed(msg.sender) notBalckListed(to) notFrozen(msg.sender)  returns (bool) {
        require(balances[msg.sender]>= msg.value ,"You don't have sufficient balance");
         _transfer(msg.sender, to, value);
        return true;
    }
    function approve(address spender, uint256 amount) public whenNotPaused notFrozen(msg.sender) notBalckListed(msg.sender) notBalckListed(spender) returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
     function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused notFrozen(sender) notBalckListed(sender) notBalckListed(recipient) returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }


    function unpause() external onlyOwner {
         paused = false;
        emit Unpaused();
    }

    

    function _transfer (address from,address to,uint256 value) internal {
        require(from !=address(0),"This Contract is not valid");
        require(to != address(0),"This Contract is not valid");

        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);

    }


}

