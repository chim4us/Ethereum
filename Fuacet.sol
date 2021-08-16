// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

interface Tkn{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract NFuacet is AccessControl{
    
    mapping(address => uint256) private _balances;
    mapping(address => bool) internal PauseAddr;
    address contractAdr;
    bool private _paused;
    uint256 private minBetAmt;
    uint256 private TotalSupply;
    
    modifier whenNotPaused(){
        require(!_paused);
        _;
    }
    
    modifier whenPaused(){
        require(_paused);
        _;
    }
    
    modifier onlyOwner (){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    
    modifier checkBetAmt(uint256 _amt){
        require(_amt >= minBetAmt, "Amount is less than minimum amount ");
        _;
    }
    
    modifier checkfreezeAdr(address _Adr){
        require(PauseAddr[_Adr] == false, "Address frozen on this contract.");
        _;
    }
    
    modifier cost (uint256 _cost,address sendr){
        Tkn Token = Tkn(contractAdr);
        uint __cost = (_cost) * (10 ** uint256(18 ));
        require(Token.balanceOf(sendr) >= __cost,"transfer amount exceeds RGN Token balance");
        _;
    }
    
    modifier CheckContractBal (address _Adr){
        require(_balances[_Adr] > 0,"Address dont have any balance");
        _;
    }
    
    event WithdrawedEvt(address account, uint amount,address perFormby);
    event BetLowHisEvt(address account, uint256 amount,uint256 Result);
    event BetHighHisEvt(address account, uint256 amount,uint256 Result);
    
    constructor(
        address _contractAdr,
        uint256 _minBetAmt
    )   {
        contractAdr = _contractAdr;
        minBetAmt = _minBetAmt;
        _paused = false;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function pause()public onlyOwner whenNotPaused{
        _paused = true;
    }
    
    function unPause()public onlyOwner whenPaused{
        _paused = false;
    }
    
    function setAdmin(address _setAdmin) public onlyOwner{
        _setupRole(DEFAULT_ADMIN_ROLE, _setAdmin);
    }
    
    function getRandom() private view returns (uint256) {
        uint source = (block.difficulty + block.timestamp) ;
        uint256 renum = uint256( keccak256(abi.encodePacked(source)) )  % 10000;
        return renum;
    }
    
    function setContractDetails(address _TknAddr, uint256 _minBetAMt) public onlyOwner{
        contractAdr = _TknAddr;
        minBetAmt = _minBetAMt;
    }
    
    function getAddressDet(address _Adr) public view returns(uint256 bal,bool Freeze){
        return(_balances[_Adr],PauseAddr[_Adr]);
    }
    
    function freezeAndUnfreezeAddress(bool _Pval,address _Adr) public onlyOwner{
        PauseAddr[_Adr] = _Pval;
    }
    
    function BetHigh(uint256 _amt) public cost(_amt,msg.sender) checkBetAmt(_amt) returns(bool result,uint256 Num){
        Tkn Token = Tkn(contractAdr);
        
        uint256 ramdomNum = getRandom();
        
        Token.transferFrom(msg.sender,address(this),_amt);
        TotalSupply += _amt;
        
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit BetHighHisEvt(msg.sender,_amt,ramdomNum);
        
        if(ramdomNum > 5250){
            _balances[msg.sender] = (_amt * 2);
            TotalSupply += _amt;
            return (true,ramdomNum);
        }else{
            return(false,ramdomNum);
        }
    }
    
    function BetLow(uint256 _amt) public cost(_amt, msg.sender) checkBetAmt(_amt) returns(bool result,uint256 Num){
        Tkn Token = Tkn(contractAdr);
        
        uint256 ramdomNum = getRandom();
        
        Token.transferFrom(msg.sender,address(this),_amt);
        TotalSupply += _amt;
        
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit BetLowHisEvt(msg.sender,_amt,ramdomNum);
        
        if(ramdomNum < 4750){
            _balances[msg.sender] = (_amt * 2);
            TotalSupply += _amt;
            return (true,ramdomNum);
        }else{
            return(false,ramdomNum);
        }
    }
    
    function getContractBal() public view onlyOwner returns (uint256 _TotalSupply, uint256 RgnBal){
        Tkn Token = Tkn(contractAdr);
        return (TotalSupply,Token.balanceOf(address(this)));
    }
    
    function withdraw() public whenNotPaused checkfreezeAdr(msg.sender) CheckContractBal (msg.sender) returns(uint){
        Tkn Token = Tkn(contractAdr);
        
        uint amoutToWith = _balances[msg.sender];
        _balances[msg.sender] = 0;
        Token.transfer(msg.sender,amoutToWith);
        
        assert(_balances[msg.sender] == 0);
        TotalSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit WithdrawedEvt(msg.sender,amoutToWith,msg.sender);
        
        return(amoutToWith);
    }
    
    function emergencyWithdraw(address _Adr ) public 
    whenPaused 
    onlyOwner 
    CheckContractBal (_Adr)
    checkfreezeAdr(_Adr) returns(uint){
        Tkn Token = Tkn(contractAdr);
        
        uint amoutToWith = _balances[_Adr];
        _balances[_Adr] = 0;
        Token.transfer(_Adr,amoutToWith);
        
        assert(_balances[_Adr] == 0);
        TotalSupply -= amoutToWith;
        assert(Token.balanceOf(address(this)) >= TotalSupply);
        
        emit WithdrawedEvt(_Adr,amoutToWith,msg.sender);
        
        return(amoutToWith);
    }
    
    function updateBal(address _Adr, uint256 _Amt)public onlyOwner{
        
    }
}
