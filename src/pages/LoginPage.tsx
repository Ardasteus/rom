import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import 'styles/HomePage.scss';
import { Redirect, Link } from 'react-router-dom';
import axios from 'classes/axios.instance';


class LoginPage extends React.Component {

  state = {
    redirectLogin: false,
    redirectRegister: false,
    name: '',
    password: '',
    authenticated: true
  };
  // Sets declarable redirectLogin true
  setRedirectLogin = () => {
    if(this.state.authenticated) {
      this.setState({
        redirectLogin: true,
      });
    }
  }
  // Sets declarable redirectRegister true
  setRedirectRegister = () => {
      this.setState({
        redirectRegister: true,
      });
    
  }

  // Handles change in name/password field
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }
  // If declarable redirectLogin is true, redirect to login page
  homeRedirect = () => {
    if (this.state.redirectLogin) {
      axios.post('/api/v1/login', {
        header: { "Content-Type": "application/json"},
        username: this.state.name,
        password: this.state.password
      })
      .then(function (response) {
        console.log(response);
      })
    }
  }
  // If declarable redirectRegister is true, redirect to register page
  registerRedirect = () => {
    if (this.state.redirectRegister) {
      return <Redirect to='/register' />;
    }
  }
  

  render() {
    const { name, password } = this.state;
    const enabled =
      name.length > 0 &&
      password.length > 0;
    return (
      <div className='login-page'>
        <img src={'public/images/homepage-background.png'} className='bg' />
        <Card className='login-card'>
          <CardContent>
            <TextField
              variant='filled'
              id='name'
              label='Name'
              margin='normal'
              value={this.state.name}
              onChange={this.handleChange('name')}
            />
            <TextField
              variant='filled'
              id='password'
              type='password'
              label='Password'
              margin='normal'
              value={this.state.password}
              onChange={this.handleChange('password')}
            />
          </CardContent>
          <CardActions>
            {this.homeRedirect()}
            <Button disabled={!enabled} onClick={this.setRedirectLogin}>Login</Button>
          </CardActions>
        </Card>
        <div>
          <Card className='register-Link'>
            <CardActions>
            {this.registerRedirect()}           
             <Button variant="contained" color="secondary" >Login</Button>
             <Button variant="contained" onClick={this.setRedirectRegister}>Register</Button>           
            </CardActions>
          </Card>
        </div>
      </div>
    );
  }
}

export default LoginPage;
