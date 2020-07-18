pragma solidity ^0.5.13;

contract Mapping{
    
    mapping(uint => string) public names;
    mapping (uint => Book) public books;
    mapping (address => mapping(uint => Book)) public MyBooks;
    
    struct Book {
        string title;
        string author;
    } 
    
    constructor() public {
        names[1] = "Frank";
        names[2] = "Emeka";
        names[3] = "Obi";
    } 
    
   function addBook(uint _id,string memory _title, string memory _author) public{
       books[_id] = Book(_title, _author);
   }
   
   function addMyBook(uint _id,string memory _title, string memory _author) public{
       MyBooks[msg.sender][_id] = Book(_title, _author);
   }
    
}
