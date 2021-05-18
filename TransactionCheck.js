const Web3 = require('web3');

class TransactionChecker{

  constructor(projectId,account){
    this.web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/v3/' + projectId));
    this.account = account.toLowerCase();
  }

  async checkBlock(){
    let block = await this.web3.eth.getBlock('latest');
    let gasUsed = block.gasUsed;
    let number = block.number;
    console.log('Searching block' + number);

    if(block != null && block.transactions != null){
      for(let txHash of block.transactions){
        let tx = await this.web3.eth.getTransaction(txHash);
        if(this.account == tx.to.toLowerCase()){
          console.log('Gas used for this transaction is ' + gasUsed);
          console.log({address: tx.from, value: this.web3.utils.fromwei(tx.value,'ether'), timestamp: new Date()})
        }
      }
    }
  }
}

let txChecker = new TransactionChecker('78dffa81deeb4e25b4a1413708d6f3d1','0x976855ddE53e42326CC5F0641ef8a3dF0c505CFb');

setInterval(()=>{
  txChecker.checkBlock();
}, 15 * 1000);
