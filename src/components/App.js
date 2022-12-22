import React, { Component }  from 'react';
import Web3 from 'web3';
import Betting from "../abis/Betting.json"
import Main from './main';
class App extends Component {

  async componentWillMount(){
    await this.loadweb3()
    await this.contactBlockchain()
  }

  async loadweb3(){
      //modern browsers
      if(window.ethereum){
        window.web3 = new Web3(window.ethereum);
          //request account access
        await window.ethereum.enable()
      }
      else{
        console.log('Non-Ethereum browser detected. Please install Metamask!')
      }
  }

  constructor(props){
    super(props)
    this.state = {
      account:'',
      wagerCount: 0,
      betCount: 0,
      loading: true,
      wagers:[],
      waitlist:[],
      bets:[]
    }
    this.addWager = this.addWager.bind(this)
    this.closeBets = this.closeBets.bind(this)
  }
  addWager(value, team, address){
    this.setState({loading: true})
    this.state.betting.methods.addWager(team, address).
    send({from: this.state.account, value: value})
    .once('receipt', (receipt)=>{
      this.state.waitlist = receipt.events
      this.setState({loading:false})
    })
  }

  closeBets(team){
    this.setState({loading: true})
    this.state.betting.methods.closeBets(team).
    send({from: this.state.account})
    .once('receipt', (receipt)=>{
      this.setState({loading:false})
    })
  }
  async contactBlockchain()
  {
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    this.setState({account: accounts[0]})
    const abi = Betting.abi
    const address = Betting.networks[5777].address
    const betting = web3.eth.Contract(abi, address)
    this.setState({betting})
    const wagerct = await betting.methods.WagerCount.call()
    for(let i = 1; i <= wagerct; i++)
    {
      const wager = await betting.methods.Wagers(i).call()
      this.setState({
        wagers: [...this.state.wagers, wager]
      })
    }
    const betct = await betting.methods.BetCount.call()
    for(let i = 1; i <= betct; i++)
    {
      const bet = await betting.methods.Bets(i).call()
      this.state.wagers[bet.wager2.id].foundMatch = true
      this.setState({
        bets: [...this.state.bets, bet]
      })
    }
    this.setState({loading: false})
  }
  render() {
    return (
          <div>
            <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
          <h2 style={{color: 'white', marginLeft: 30}}>
            Decentralized Betting
          </h2>
          <ul style={{color: 'white', marginRight: 30}}>{this.state.account}</ul>
        </nav>
        <div> 
            <main role="main">
            {this.state.loading
            ? <div style={{marginTop: "100px"}}> <p> Loading ... </p> </div> 
            : <Main
              wagers={this.state.wagers}
              bets={this.state.bets}
              addWager={this.addWager}
              closeBets={this.closeBets}/>}
            </main>
          </div>
        </div>
    );
  }
}

export default App;
