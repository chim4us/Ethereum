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

contract NumFuacet is AccessControl{
    mapping(uint256 => uint256) VotedNum;
    uint256 startFrm;
    uint256 endTo;
    uint256 minimunBetAmt;
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    struct bet{
        address beterAddress;
        uint256 choice1;
        uint256 choice2;
        uint256 choice3;
        uint256 choice4;
        uint256 choice5;
        uint256 BetAmt;
        bool Paidout;
        bool Won;
    }
    
    struct WonBet{
        uint256 num1;
        uint256 num2;
        uint256 num3;
        uint256 num4;
        uint256 num5;
    }
    
    uint256 totalBets = 0;
    
    mapping(uint => bet) private bets;
    
    mapping(uint => WonBet) public wonbets;
    
    address payable contractAdr;
    
    enum State{Created, Betting, Ended}
    
    State public state;
    
    modifier onlyOwner (){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    
    modifier checkRange (uint256 _startFrm,uint256 _endTo){
        require(_startFrm < _endTo,"");
        _;
    }
    
    modifier instate(State _state){
        require(state == _state);
        _;
    }
    
    event betEvt(address account, uint betNum,uint date);
    event wonPayOut(address account, uint256 betAmt,uint256 paidAmt,uint256 betTicket);
    
    constructor(
        uint256 _startFrm,
        uint256 _endTo,
        uint256 _minimunBetAmt,
        address payable _contractAdr
    )   checkRange(_startFrm,_endTo){
        startFrm = _startFrm;
        endTo = _endTo;
        minimunBetAmt = _minimunBetAmt;
        contractAdr = payable(_contractAdr);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function placeBet(uint256 _choice1,
        uint256 _choice2,
        uint256 _choice3,
        uint256 _choice4,
        uint256 _choice5,uint256 _Amt) public instate(State.Betting) {
        require(_choice1 >= startFrm && _choice1 <= endTo,"");
        require(_choice2 >= startFrm && _choice2 <= endTo,"");
        require(_choice3 >= startFrm && _choice3 <= endTo,"");
        require(_choice4 >= startFrm && _choice4 <= endTo,"");
        require(_choice5 >= startFrm && _choice5 <= endTo,"");
        Tkn Token = Tkn(contractAdr);
        require(Token.balanceOf(msg.sender) >= minimunBetAmt,"");
        require(Token.balanceOf(msg.sender) >= _Amt,"");
        
        Token.transferFrom(msg.sender,address(this),_Amt);
        bet memory b;
        b.beterAddress = msg.sender;
        b.choice1 = _choice1;
        b.choice2 = _choice2;
        b.choice3 = _choice3;
        b.choice4 = _choice4;
        b.choice5 = _choice5;
        b.BetAmt = _Amt;
        b.Paidout = false;
        b.Won = false;
        
        VotedNum[_choice1] += 1;
        VotedNum[_choice2] += 1;
        VotedNum[_choice3] += 1;
        VotedNum[_choice4] += 1;
        VotedNum[_choice5] += 1;
        
        bets[totalBets] = b;
        
        emit betEvt(msg.sender,totalBets,block.timestamp);
        
        totalBets++;
    }
    
    function setAdmin(address _setAdmin) public onlyOwner{
        _setupRole(DEFAULT_ADMIN_ROLE, _setAdmin);
    }
    
    function pickWinsNum() public instate(State.Ended)
    //returns (uint256 _num1, uint256 _num2,uint256 _num3,uint256 _num4,uint256 _num5)
    {
        uint256 lockyNum1 = 0;
        uint256 lockyNum2 = 0;
        uint256 lockyNum3 = 0;
        uint256 lockyNum4 = 0;
        uint256 lockyNum5 = 0;
        
        uint256 vlockyNum1 = 1;
        uint256 vlockyNum2 = 1;
        uint256 vlockyNum3 = 1;
        uint256 vlockyNum4 = 1;
        uint256 vlockyNum5 = 1;
        for(uint256 i = startFrm; i <= endTo; i++){
            if ((vlockyNum1 >=  VotedNum[i]) && (VotedNum[i] > 0)){
                lockyNum1 = i;
                vlockyNum1 = VotedNum[i];
            }
            
            if ((vlockyNum2 >=  VotedNum[i]) && (VotedNum[i] > 0)
            && (i != lockyNum1)){
                lockyNum2 = i;
                vlockyNum2 = VotedNum[i];
            }
            
            if ((vlockyNum3 >=  VotedNum[i]) && (VotedNum[i] > 0)
            && (i != lockyNum1)
            && (i != lockyNum2)){
                lockyNum2 = i;
                vlockyNum3 = VotedNum[i];
            }
            
            if ((vlockyNum4 >=  VotedNum[i]) && (VotedNum[i] > 0)
            && (i != lockyNum1)
            && (i != lockyNum2)
            && (i != lockyNum3)){
                lockyNum4 = i;
                vlockyNum4 = VotedNum[i];
            }
            
            if ((vlockyNum5 >=  VotedNum[i]) && (VotedNum[i] > 0)
            && (i != lockyNum1)
            && (i != lockyNum2)
            && (i != lockyNum3)
            && (i != lockyNum4)){
                lockyNum5 = i;
                vlockyNum5 = VotedNum[i];
            }
        }
        state = State.Created;
        
        WonBet memory b; 
        b.num1 = lockyNum1;
        b.num2 = lockyNum2;
        b.num3 = lockyNum3;
        b.num4 = lockyNum4;
        b.num5 = lockyNum5;
        
        wonbets[block.timestamp] = b;
        
        //return(lockyNum1,lockyNum2,lockyNum3,lockyNum4,lockyNum5);
        
    }
    
    function endBets()
    public
    instate(State.Betting)
    onlyOwner
    {
        state = State.Ended;
    }
    
    function startBets()
    public
    instate(State.Created)
    onlyOwner
    {
        state = State.Betting;
    }
    
    function CheckBetsNumOnAddress(address _adr) public view returns(address [] memory){
        
    }
    
    function ClaimBet(uint256 betnum,uint256 betdate)public {
        require(bets[betnum].beterAddress == msg.sender,"Bet was not placed by your address");
        Tkn Token = Tkn(contractAdr);
        uint256 AdrWonBet = 0;
        
        if((bets[betnum].choice1 == wonbets[betdate].num1) || 
        (bets[betnum].choice1 == wonbets[betdate].num2) ||
        (bets[betnum].choice1 == wonbets[betdate].num3) ||
        (bets[betnum].choice1 == wonbets[betdate].num4) ||
        (bets[betnum].choice1 == wonbets[betdate].num5)){
            AdrWonBet++;
        }
        
        if((bets[betnum].choice2 == wonbets[betdate].num1) || 
        (bets[betnum].choice2 == wonbets[betdate].num2) ||
        (bets[betnum].choice2 == wonbets[betdate].num3) ||
        (bets[betnum].choice2 == wonbets[betdate].num4) ||
        (bets[betnum].choice2 == wonbets[betdate].num5)){
            AdrWonBet++;
        }
        
        if((bets[betnum].choice3 == wonbets[betdate].num1) || 
        (bets[betnum].choice3 == wonbets[betdate].num2) ||
        (bets[betnum].choice3 == wonbets[betdate].num3) ||
        (bets[betnum].choice3 == wonbets[betdate].num4) ||
        (bets[betnum].choice3 == wonbets[betdate].num5)){
            AdrWonBet++;
        }
        
        if((bets[betnum].choice4 == wonbets[betdate].num1) || 
        (bets[betnum].choice4 == wonbets[betdate].num2) ||
        (bets[betnum].choice4 == wonbets[betdate].num3) ||
        (bets[betnum].choice4 == wonbets[betdate].num4) ||
        (bets[betnum].choice4 == wonbets[betdate].num5)){
            AdrWonBet++;
        }
        
        if((bets[betnum].choice5 == wonbets[betdate].num1) || 
        (bets[betnum].choice5 == wonbets[betdate].num2) ||
        (bets[betnum].choice5 == wonbets[betdate].num3) ||
        (bets[betnum].choice5 == wonbets[betdate].num4) ||
        (bets[betnum].choice5 == wonbets[betdate].num5)){
            AdrWonBet++;
        }
        
        if(AdrWonBet >= 2){
            bets[betnum].Won = true;
        }
        
        if((bets[betnum].Won) && (!bets[betnum].Paidout)){
            bets[betnum].Paidout = true;
            Token.transfer(msg.sender,(bets[betnum].BetAmt * 10));
            emit wonPayOut(msg.sender,bets[betnum].BetAmt,(bets[betnum].BetAmt * 10),betnum);
        }
    }
    
    function setBetRange(uint256 _startFrm,
        uint256 _endTo) public onlyOwner checkRange(_startFrm,_endTo) instate(State.Created){
        startFrm = _startFrm;
        endTo = _endTo;
    }
    
}
