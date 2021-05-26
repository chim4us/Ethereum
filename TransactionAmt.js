const Web3 = require('web3');
var accounts = "0x5Fe227FFbe7Df1484CB049bb14c0424A69850f6B"
var projectId = "78dffa81deeb4e25b4a1413708d6f3d1"

async function checkBlock(projectId,accounts) {
    web3 = new Web3(new Web3.providers.HttpProvider('https://mainnet.infura.io/v3/' + projectId));
    var account = accounts.toLowerCase();
    let block = await web3.eth.getBlock('latest');
    let bnumber = block.number;
    //let fblock = block.number - 0;
    let fblock =  12231088;
    for(var b = fblock; b <= bnumber; b++){
        let cblock = await this.web3.eth.getBlock(b);
        if(cblock != null && cblock.transactions != null){
            for(let txHash of cblock.transactions){
                let tx = await this.web3.eth.getTransaction(txHash);
                if(tx != null){
                    var fromAcct = (tx.from?tx.from:'').toLowerCase();
                    var toAcct = (tx.to?tx.to:'').toLowerCase();
                    if(account == fromAcct){
                        conAddress = tx.to.toLowerCase();
                        var inp = tx.input;
                        if(inp.length == 138){
                            var inp1 = inp.substring(10);
                            var inp2 = inp1.substring(64);
                            let AmountVal = parseInt(inp2, 16);
                            console.log("Amount is 1 "+AmountVal);
                            console.log("Account is 1 "+conAddress);
                        }else{
                            var inp1 = inp.substring(10);
                            let AmountVal = parseInt(inp1, 16);
                            console.log("Amount is 2 "+AmountVal);
                            console.log("Account is 2 "+conAddress);
                        }
                        
                    }else if(account == toAcct){
                        conAddress = tx.from.toLowerCase();
                        var inp = tx.input;
                        if(inp.length == 138){
                            var inp1 = inp.substring(10);
                            var inp2 = inp1.substring(64);
                            let AmountVal = parseInt(inp2, 16);
                            console.log("Account is 3 "+conAddress);
                            console.log("Amount is 3 "+AmountVal);
                        }else{
                            var inp1 = inp.substring(10);
                            let AmountVal = parseInt(inp1, 16);
                            console.log("Account is 4 "+conAddress);
                            console.log("Amount is 4 "+AmountVal);
                        }
                    }
                }
            }
        }
    }

}

checkBlock(projectId,accounts);
