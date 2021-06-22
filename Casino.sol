import "./Ownable.sol";
import "./Destroyable.sol";
pragma solidity  <= 0.5.12 < 0.9.0 ;

contract casino is ownable, Destroyable{
    //variables
    struct Member{
        uint id;
        address  ref;
        PlayerState stage;
        //address 
    }
    
    struct adrNetwork{
        address referedFirst;
        address referedSecond;
        bool refCompleted;
    }
    
    enum PlayerState{stage0,stage1, stage2, stage3, stage4, stage5}
    PlayerState private state;
    PlayerState constant defaultState = PlayerState.stage1;
    
    mapping(address => uint) private Ballances;
    mapping(address => Member) private Creator;
    mapping(address => adrNetwork) private NetTree;
    
    address[] private Creators;
    
    uint private MembCount = 1;
    uint private TotalSupply;
    //uint private FeeAmt = 20 finney;
    
    //modifiers
    modifier cost (uint _cost){
        require(msg.value >= _cost);
        _;
    }
    
    modifier checkRef (address _ref){
        require(!NetTree[_ref].refCompleted);
        require(Creator[_ref].id > 0);
        _;
    }
    
    //events
    event WithdrawedEvt(address account, uint amount,address perFormby);
    event JoinedEvt(address account, uint id, address ref);
    event UpgradeEvt(address account,uint paidAmt, uint upGraadeAmt, address PaidAdr);
    
    //functions
    constructor() public{
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = owner;
        newMember.stage = defaultState;
        
        adrNetwork memory newAdrNetwork;
        newAdrNetwork.referedFirst = owner;
        newAdrNetwork.referedSecond = owner;
        newAdrNetwork.refCompleted = false;
        
        InsertPerson(newMember,newAdrNetwork);
        Creators.push(msg.sender);
        
        assert(keccak256(abi.encodePacked(
            Creator[msg.sender].id,
            Creator[msg.sender].ref,
            Creator[msg.sender].stage))
            ==
            keccak256(abi.encodePacked(
            newMember.id,
            newMember.ref,
            newMember.stage))
        );
        
        MembCount += 1;
    }
    
    function getAddrDetails(address _adr) public view returns 
    (uint Bal, uint id,address referedBy, PlayerState stage, address referedFirst, address referedSecond ){
        uint _bal = Ballances[_adr];
        return (_bal,
        Creator[_adr].id,
        Creator[_adr].ref,
        Creator[_adr].stage,
        NetTree[_adr].referedFirst,
        NetTree[_adr].referedSecond);
    }
    
    function Join(address _ref) public payable checkRef(_ref) cost(30 finney){
        require(_ref != msg.sender,"You can't refer your account");
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = _ref;
        newMember.stage = defaultState;
        
        adrNetwork memory newAdrNetwork;
        newAdrNetwork.referedFirst = address(0);
        newAdrNetwork.referedSecond = address(0);
        newAdrNetwork.refCompleted = false;
        
        InsertPerson(newMember,newAdrNetwork);
        Creators.push(msg.sender);
        
        address referedFirst = NetTree[_ref].referedFirst;
        address referedSecond = NetTree[_ref].referedSecond;
        
        if(referedFirst == address(0)){
            NetTree[_ref].referedFirst = msg.sender;
        }else if(referedSecond == address(0)){
            NetTree[_ref].referedSecond = msg.sender;
            if(_ref != owner){
                NetTree[_ref].refCompleted = true;
            }
        }
        
        assert(keccak256(abi.encodePacked(
            Creator[msg.sender].id,
            Creator[msg.sender].ref,
            Creator[msg.sender].stage))
            ==
            keccak256(abi.encodePacked(
            newMember.id,
            newMember.ref,
            newMember.stage))
        );
        
        AddBal(_ref);
        TotalSupply += msg.value;
        assert(address(this).balance >= TotalSupply);
        emit JoinedEvt (msg.sender, MembCount, _ref);
        MembCount += 1;
    }
    
    function Upgrade() public payable cost(50 finney) returns(address){
        PlayerState refStage = Creator[msg.sender].stage;
        address _ref = Creator[msg.sender].ref;
        uint  count;
        uint amt;
        uint dif;
        if(refStage == PlayerState.stage1){
            require(msg.value >= 50 finney,"Value must be greater than 0.04 ether");
            count = 1;
            amt = 50 finney;
            dif = msg.value - amt;
            Creator[msg.sender].stage = PlayerState.stage2;
        }else if(refStage == PlayerState.stage2){
            require(msg.value >= 100 finney,"Value must be greater than 0.10 ether");
            count = 2;
            amt = 100 finney;
            dif = msg.value - amt;
            Creator[msg.sender].stage = PlayerState.stage3;
        }else if(refStage == PlayerState.stage3){
            require(msg.value >= 400 finney,"Value must be greater than 0.40 ether");
            count = 3;
            amt = 400 finney;
            dif = msg.value - amt;
            Creator[msg.sender].stage = PlayerState.stage4;
        }else if(refStage == PlayerState.stage4){
            require(msg.value >= 1000 finney,"Value must be greater than 1 ether");
            count = 4;
            amt = 1000 finney;
            dif = msg.value - amt;
            Creator[msg.sender].stage = PlayerState.stage5;
        }else if(refStage == PlayerState.stage5){
            require(msg.value >= 1000 finney,"Value must be greater than 1 ether");
            count = 5;
            amt = msg.value;
            dif = 0;
            Creator[msg.sender].stage = PlayerState.stage5;
        }
        
        if(refStage != PlayerState.stage5){
            uint i = 1;
            while(i < count) {
                _ref = Creator[_ref].ref;
                if(_ref == address(0)){
                    _ref = owner;
                }
                i++;
            }
        }else{
            _ref = owner;
        }
        Ballances[_ref] += amt;
        Ballances[owner] += dif;
        TotalSupply += msg.value;
        assert(address(this).balance >= TotalSupply);
        emit UpgradeEvt(msg.sender,msg.value,amt,_ref);
        return (_ref);
    }
    
    function InsertPerson(Member memory _newMember, adrNetwork memory _newAdrNetwork) private{
        address NewCreator = msg.sender;
        Creator[NewCreator] = _newMember;
        NetTree[NewCreator] = _newAdrNetwork;
    }
    
    function AddBal(address _ref) private{
        PlayerState refStage = Creator[_ref].stage;
        if(refStage == PlayerState.stage1){
            uint diff = msg.value - 30 finney;
            Ballances[_ref] += 30 finney;
            Ballances[owner] += diff;
        }else{
            Ballances[owner] += msg.value;
        }
    }
    
    function ContractBal() public view onlyOwner returns(uint ){
        return address(this).balance;
    }
    
    function withdraw() public payable whenNotPaused returns(uint){
        require(Ballances[msg.sender] > 0);
        uint amoutToWith = Ballances[msg.sender];
        Ballances[msg.sender] = 0;
        msg.sender.transfer(amoutToWith);
        
        assert(Ballances[msg.sender] == 0);
        TotalSupply -= amoutToWith;
        assert(address(this).balance >= TotalSupply);
        
        emit WithdrawedEvt(msg.sender,amoutToWith,msg.sender);
        return amoutToWith;
    }
    
    function withdrawEx() public payable onlyOwner whenNotPaused returns(uint){
        uint conBal = address(this).balance;
        uint diff = conBal - TotalSupply;
        msg.sender.transfer(diff);
        assert(address(this).balance >= TotalSupply);
        emit WithdrawedEvt(msg.sender,diff,msg.sender);
        return diff;
    }
    
    function emergencyWithdraw(address payable _adrToWith) public payable onlyOwner whenPaused returns(uint){
        require(Ballances[_adrToWith] > 0);
        uint amoutToWith = Ballances[_adrToWith];
        Ballances[_adrToWith] = 0;
        _adrToWith.transfer(amoutToWith);
        
        assert(Ballances[_adrToWith] == 0);
        TotalSupply -= amoutToWith;
        assert(address(this).balance >= TotalSupply);
        
        emit WithdrawedEvt(_adrToWith,amoutToWith,msg.sender);
        return amoutToWith;
    }
}
