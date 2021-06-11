import "./Ownable.sol";
import "./Destroyable.sol";
import "./safeMath.sol";
pragma solidity  <= 0.5.12 < 0.9.0 ;

contract casino is ownable{
    //variables
    struct Member{
        uint id;
        address  ref;
        PlayerState stage;
    }
    
    enum PlayerState{stage1, stage2, stage3, stage4, stage5}
    PlayerState public state;
    PlayerState constant defaultState = PlayerState.stage1;
    
    mapping(address => uint) private Ballances;
    mapping(address => Member) private Creator;
    
    address[] private Creators;
    
    uint private MembCount = 1;
    //uint private FeeAmt = 20 finney;
    
    //modifiers
    modifier cost (uint _cost){
        require(msg.value >= _cost);
        _;
    }
    
    //events
    event WithdrawedEvt(address account, uint amount);
    event JoinedEvt(address account, uint id, address ref);
    
    //functions
    function getAddrBal(address _adr) public view onlyOwner returns (uint Bal){
        return (Ballances[_adr]);
    }
    
    function Join(address _ref) public payable cost(30 finney){
        
        Member memory newMember;
        newMember.id = MembCount;
        newMember.ref = _ref;
        newMember.stage = defaultState;
        InsertPerson(newMember);
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
        
        AddBal(_ref);
        emit JoinedEvt (msg.sender, MembCount, _ref);
        MembCount += 1;
    }
    
    function getPromoted() public payable cost(30 finney){
        PlayerState refStage = Creator[msg.sender].stage;
        if(refStage == PlayerState.stage1){
            
        }else if(refStage == PlayerState.stage2){
            
        }else if(refStage == PlayerState.stage3){
            
        }else if(refStage == PlayerState.stage4){
            
        }else if(refStage == PlayerState.stage5){
            
        }
    }
    
    function InsertPerson(Member memory _newMember) private{
        address NewCreator = msg.sender;
        Creator[NewCreator] = _newMember;
    }
    
    function AddBal(address _ref) private{
        PlayerState refStage = Creator[_ref].stage;
        if(refStage == PlayerState.stage1){
            uint diff = msg.value - 20 finney;
            Ballances[_ref] += 20 finney;
            Ballances[owner] += diff;
        }else{
            Ballances[owner] += msg.value;
        }
    }
    
    function withdraw() public payable returns(uint){
        uint amoutToWith = Ballances[msg.sender];
        Ballances[msg.sender] = 0;
        msg.sender.transfer(amoutToWith);
        emit WithdrawedEvt(msg.sender,amoutToWith);
        return amoutToWith;
    }
}
