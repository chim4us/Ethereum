pragma solidity ^0.6.0;


contract HotelRoom{
    address payable public owner;
    
    enum Statuses { Vacant,Occupied }
    Statuses currentStatus;
    event Occupy(address _occupant, uint _value);
    
    constructor() public{
        owner = msg.sender;
        currentStatus = Statuses.Vacant;
    }
    
    modifier onlyWhileVacant{
        require(currentStatus == Statuses.Vacant, "Currently Occupied");
        _;
    }
    
    modifier cost(uint _amount){
        require(msg.value >= _amount,"Not Enough Value");
        _;
    }
    
    receive() external payable onlyWhileVacant cost(2 ether){
        currentStatus == Statuses.Occupied;
        owner.transfer(msg.value);
        emit Occupy(msg.sender,msg.value);
    }
}
