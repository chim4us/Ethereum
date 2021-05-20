const Web3 = require('web3');

let accountsgas =  [];
let current_page = 1;
let row = 5;

async function checkBlock(projectId,accounts) {
  this.web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/v3/' + projectId));
  for (var i = 0; i < accounts.length; i++) {
    var account = accounts[i].toLowerCase();
    //Get the latest block
    let block = await this.web3.eth.getBlock('latest');
    let bnumber = block.number;
    let fblock = block.number - 5760;
    let tgasUsed = 0;
    //loop through the blocks mine today
    for(var b = fblock; b <= bnumber; b++){
      let cblock = await this.web3.eth.getBlock(b);
      let gasUsed = cblock.gasUsed;
      if(cblock != null && cblock.transactions != null){
        for(let txHash of cblock.transactions){
          let tx = await this.web3.eth.getTransaction(txHash);
          if(this.account == tx.from.toLowerCase()){
            tgasUsed += gasUsed;
          }
        }
      }
    }
    //Push the result to an array
    accountsgas.push({Address: account,gasused: tgasUsed})
  }
}

function DisplayList(item,rows_per_page,page){
  page --;
  let loop_start = rows_per_page * page;
  let paginatedItems = item.slice(loop_start,loop_start + rows_per_page);
  console.log(paginatedItems);

}

checkBlock('78dffa81deeb4e25b4a1413708d6f3d1', ['0x976855ddE53e42326CC5F0641ef8a3dF0c505CFb','0x976855ddE53e42326CC5F0641ef8a3dF0c505CFb','0x976855ddE53e42326CC5F0641ef8a3dF0c505CFb']);

DisplayList(accountsgas,row,current_page);
