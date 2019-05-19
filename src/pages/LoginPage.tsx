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
      
      <div className="login-page">   
        <img src={'public/images/homepage-background.png'} className='bg' />
      <Card className="login-card">
      <CardContent>
      <TextField
          id="standard-name"
          label="Name"
          margin="normal"
        />
        <TextField
          id="standard-password"
          label="Password"
          margin="normal"
        />
      </CardContent>
      <CardActions>
        {this.homeRedirect()}       
        <Button onClick={this.setRedirect}>Login</Button>
      </CardActions>
      </Card>
      <div>
        <Card className="register-Link">
          <CardContent>
          <p>If you dont have an account </p><p><Link to="/register">Register</Link></p>
          </CardContent>
        </Card>
      </div>  
    </div>
    );
  }
}

export default LoginPage;
