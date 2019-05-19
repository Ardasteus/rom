import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import { withStyles } from '@material-ui/core/styles';
import MenuItem from '@material-ui/core/MenuItem';
import TextField from '@material-ui/core/TextField';
import 'styles/HomePage.scss';
import { Redirect, Link } from 'react-router-dom'





class LoginPage extends React.Component {

  state = {
    redirect: false
  }
  setRedirect = () => {
    this.setState({
      redirect: true
    })
  }
  homeRedirect = () => {
    if (this.state.redirect) {
      return <Redirect to='/home' />
    }
  }
  

  render() {
    return (
      
      <div className="create-page">   
        <img src={'public/images/homepage-background.png'} className='bg' />
      <Card className="create-card">
      <CardContent>
      <TextField
          id="new-name"
          label="Choose a Name"
          margin="normal"
        />
        <TextField
          id="new-password"
          label="Create a Password"
          margin="normal"
        />
        <TextField
          id="confirm-password"
          label="Confirm your Password"
          margin="normal"
        />
      </CardContent>
      <CardActions>
        {this.homeRedirect()}       
        <Button onClick={this.setRedirect}>Create account</Button>
      </CardActions>
      </Card>
      <div>
        <Card className="login-Link">
          <CardContent>
          <p>If you have an account already </p><p><Link to="/">Login</Link></p>
          </CardContent>
        </Card>
      </div>  
    </div>
    );
  }
}

export default LoginPage;
