import { thisExpression } from "@babel/types"
import React from "react"
import web3 from "web3"

class Main extends React.Component{
    render(){
        return( 
            <div>
            <h1> 
                Welcome
            </h1>
            <h2>Place Wager</h2>
        <div style={styles.wrapper}>
            <img src="https://freepngimg.com/save/13010-dallas-cowboys-png-clipart/1200x1200" width="200" height="200"/>
            <h1 style={styles.vstext}>Vs.</h1>
            <img src="https://www.festisite.com/static/partylogo/img/logos/broncos.png" width="240" height="200"/>
        </div>
        <div style={styles.textboxes}>
        <form onSubmit={(event) => {
          event.preventDefault()
          const team = "DAL"
          const value = window.web3.utils.toWei(this.amount.value.toString(), 'Ether')
          let addr = this.refs.pref.value.toString()
          if(!addr) addr = "0x0000000000000000000000000000000000000000"
          this.props.addWager(value, team, addr)
        }}> 
          <div style={styles.form1}>
            <input
              id="Team1Wager"
              type="text"
              ref={(input) => { this.amount = input }}
              className="form-control"
              placeholder="Wager Amount"
              required />
          </div>
          <div style={styles.form1}>
            <input
              id="Team1WagerPref"
              type="text"
              ref="pref"
              className="form-control"
              placeholder="Preference address"
               />
          </div>
          <button type="submit" className="btn btn-primary">Place Wager</button>
            </form>
        <form onSubmit={(event) => {
          event.preventDefault()
          const team = "BRO"
          const value = window.web3.utils.toWei(this.value.value.toString(), 'Ether')
          let addr = this.refs.preff.value.toString()
          if(!addr) addr = "0x0000000000000000000000000000000000000000"
          this.props.addWager(value, team, addr)
        }}>
            <div style={styles.form1}>
                <input
                id="Team2Wager"
                type="text"
                ref={(input) => { this.value = input }}
                className="form-control"
                placeholder="Wager Amount"
                required />
            </div>
            <div style={styles.form1}>
            <input
              id="Team1Wager"
              type="text"
              ref="preff"
              className="form-control"
              placeholder="Preference address"
              />
          </div>
          <div style={styles.textboxes}>
          <button type="submit2" className="btn btn-primary"style={{marginRight:"30px"}}>Place Wager</button>
          </div>
          </form>
          </div>
          
        <div style={{marginTop: "25px"}}>
            <h2> Wagers </h2>
            <table className="table">
                <thead>
                <tr>
                <th scope="col">#</th>
                <th scope="col">Bettor</th>
                <th scope="col">Team</th>
                <th scope="col">Amount</th>
                <th scope="col">Matched</th>
                </tr>    
                </thead>
                <tbody>
                    {this.props.wagers.map((wager, key)=>
                    {
                        return(
                            <tr key={key}>
                                <th scope="row">{wager.id.toString()}</th>
                                <td>{wager.Bettor.toString()}</td>
                                <td>{wager.Team.toString()}</td>
                                <td>{window.web3.utils.fromWei(wager.Amount.toString(), "Ether") + " ETH"}</td>
                                <td>{
                                wager.foundMatch.toString()
                                }</td>
                            </tr>
                        )
                    })}
                </tbody>
            </table>
        </div>
        <div style={{marginTop: "25px"}}>
            <h2> Bets </h2>
            <table className="table">
                <thead>
                <tr>
                <th scope="col">#</th>
                <th scope="col">Team 1</th>
                <th scope="col">Team 2</th>
                <th scope="col">Amount</th>
                </tr>    
                </thead>
                <tbody>
                    {this.props.bets.map((bet, key)=>
                    {
                        return(
                            <tr key={key}>
                                <th scope="row">{bet.id.toString()}</th>
                                <td>{bet.wager1.Bettor.toString()}</td>
                                <td>{bet.wager2.Bettor.toString()}</td>
                                <td>{window.web3.utils.fromWei(bet.wager1.Amount.toString(), "Ether") + " ETH"}</td>
                            </tr>
                        )
                    })}
                </tbody>
            </table>
            </div>
        <div style={styles.textboxes}>
        <form onSubmit={(event) => {
          event.preventDefault()
          const team = this.team.value.toString()
          this.props.closeBets(team)
        }}> 
          <div style={styles.form1}>
            <input
              id="Team1Wager"
              type="text"
              ref={(input) => { this.team = input }}
              className="form-control"
              placeholder="Winner Team"
              required />
          <button type="submit2" className="btn btn-primary"style={{marginRight:"30px"}}>Close Bets</button>
          </div>
        </form>
        </div>
        </div>
    )
    }
}
export default Main

const styles = {
    wrapper: {
      display: "flex",
      justifyContent: "space-between",
      maxWidth: "1000px",
      border: "1px solid #e6e6e6",
      marginTop: "30px"
    },
    vstext:{
        marginTop: "50px",
        fontWeight: "bold"
    },
    form1:{
        maxWidth: "300px",
        marginTop: "15px",
        marginBottom: "15px",
    },
    textboxes:{
        maxWidth: "1000px",
        display: "flex",
        justifyContent: "space-between",
    }
  };