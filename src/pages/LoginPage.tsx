import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import 'styles/HomePage.scss';
import { Redirect, Link } from 'react-router-dom';

class LoginPage extends React.Component {

  state = {
    redirect: false,
    redirect1: false,
    name: '',
    password: '',
  };

  setRedirect = () => {
    if (this.state.name === 'admin' && this.state.password === '123456') {
      this.setState({
        redirect: true,
      });
    }
  }

  setRedirect1 = () => {
      this.setState({
        redirect1: true,
      });
    
  }


  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }

  homeRedirect = () => {
    if (this.state.redirect) {
      return <Redirect to='/home' />;
    }
  }
  registerRedirect = () => {
    if (this.state.redirect1) {
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
            <Button disabled={!enabled} onClick={this.setRedirect}>Login</Button>
          </CardActions>
        </Card>
        <div>
          <Card className='register-Link'>
            <CardActions>
            {this.registerRedirect()}           
             <Button variant="contained" color="secondary" >Login</Button>
             <Button variant="contained" onClick={this.setRedirect1}>Register</Button>           
            </CardActions>
          </Card>
        </div>
      </div>
    );
  }
}

export default LoginPage;
