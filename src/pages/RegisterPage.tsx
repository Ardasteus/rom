import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import { withStyles } from '@material-ui/core/styles';
import MenuItem from '@material-ui/core/MenuItem';
import TextField from '@material-ui/core/TextField';
import 'styles/HomePage.scss';
import { Redirect, Link } from 'react-router-dom';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

class RegisterPage extends React.Component {

  state = {
    redirectSignIn: false,
    redirectLogin: false,
    open: false,
    name: '',
    password: '',
    conpassword: '',
  };
  // Sets declarable redirectSignIn true
  setRedirectSignIn = () => {
    this.setState({
      redirectSignIn: true,
    });
  }
  // Sets declarable redirectLogin true
  setRedirectLogin = () => {
    this.setState({
      redirectLogin: true,
    });
  }
  // If declarable redirectSignIn is true, redirect to home page
  homeRedirect = () => {
    if (this.state.redirectSignIn) {
      return <Redirect to='/home' />;
    }
  }
  // If declarable redirectLogin is true, redirect to login page
  loginRedirect = () => {
    if (this.state.redirectLogin) {
      return <Redirect to='/' />;
    }
  }
  // Handles create account dialog
  handleClickOpen = () => {
    this.setState({ open: true });
  }

  // Handles change in name/password field
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }

  render() {
    const { name, password, conpassword } = this.state;
    const enabled =
          this.state.password == this.state.conpassword &&
          name.length > 0 &&
          password.length > 0 &&
          conpassword.length > 0;
    return (

      <div className='create-page'>
        <img src={'public/images/homepage-background.png'} className='bg' />
      <Card className='create-card'>
      <CardContent>
      <TextField
          variant='filled'
          id='new-name'
          label='Choose a Name'
          margin='normal'
          value={this.state.name}
          onChange={this.handleChange('name')}
        />
        <TextField
          variant='filled'
          id='new-password'
          label='Create a Password'
          type='password'
          margin='normal'
          value={this.state.password}
          onChange={this.handleChange('password')}
        />
        <TextField
          variant='filled'
          id='confirm-password'
          label='Confirm your Password'
          type='password'
          margin='normal'
          value={this.state.conpassword}
          onChange={this.handleChange('conpassword')}
        />
      </CardContent>
      <CardActions>
        <Button disabled={!enabled} onClick={this.handleClickOpen}>Create account</Button>
      </CardActions>
      </Card>
      <Dialog
          open={this.state.open}
          aria-labelledby='alert-dialog-title'
          aria-describedby='alert-dialog-description'
        >
          <DialogTitle id='alert-dialog-title'>{'You have succesfully created an account'}</DialogTitle>
          <DialogContent>
            <DialogContentText id='alert-dialog-description'>
            </DialogContentText>
          </DialogContent>
          <DialogActions>
          {this.homeRedirect()}
            <Button onClick={this.setRedirectSignIn} color='primary' autoFocus>
              Ok
            </Button>
          </DialogActions>
        </Dialog>
      <div>
        <Card className='login-Link'>
          <CardActions>
            {this.loginRedirect()}                        
             <Button variant="contained" onClick={this.setRedirectLogin}>Login</Button>        
             <Button variant="contained" color="secondary">Register</Button>   
            </CardActions>
         </Card>
      </div>
    </div>
    );
  }
}

export default RegisterPage;
