import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import 'styles/HomePage.scss';
import { Redirect, Link } from 'react-router-dom';
import axios from 'classes/axios.instance';
import { createMuiTheme } from '@material-ui/core/styles';
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider';

const theme = createMuiTheme({
  palette: {
      primary: {
          main: '#000000',
          light: '#ffffff',
      },
      secondary: {
          main: '#b71c1c',
      },
  },
});

class LoginPage extends React.Component {

  state = {
    redirectLogin: false,
    redirectRegister: false,
    name: '',
    password: '',
    authenticated: true,
  };

  /**
   * Posts username and password textfields values to the API, if status is 201 then set state redirectLogin true, localstorage received token */ 
  setRedirectLogin = () => {
    axios.post('login', {
      username: this.state.name,
      password: this.state.password,
    }).then(response => {
      if (response.status === 201 && this.state.authenticated) {
        this.setState({ redirectLogin: true });
        localStorage.setItem('token', response.data.token);
      }
    });
  }

  /**
   * Sets state redirectRegister to true  */ 
  setRedirectRegister = () => {
      this.setState({
        redirectRegister: true,
      });
  }

  /**
   * Handles change in name/password field */ 
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }

  /**
   * Redirects to home page */ 
  homeRedirect =() => {
    return <Redirect to='/home' />;
  }
  /**
   * Redirects to register page */ 
  registerRedirect = () => {
      return <Redirect to='/register' />;
  }

  render() {
    const { name, password } = this.state;
    const enabled = name.length > 0 && password.length > 0;

    if (this.state.redirectLogin) {
      return this.homeRedirect();
    }

    if (this.state.redirectRegister) {
      return this.registerRedirect();
    }

    return (
      <div className='login-page'>
        <MuiThemeProvider theme={theme}>
        <img src={'public/images/homepage-background.jpg'} className='bg' />
        <Card className='login-card' color='primary'>
          <CardContent>
            <TextField
              variant='outlined'
              color='secondary'
              id='name'
              label='Name'
              margin='normal'
              value={this.state.name}
              onChange={this.handleChange('name')}
            />
            <TextField 
              variant='outlined'
              color='secondary'
              id='password'
              type='password'
              label='Password'
              margin='normal'
              value={this.state.password}
              onChange={this.handleChange('password')}
            />
          </CardContent>
          <CardActions>

            <Button variant='contained' disabled={!enabled} color='secondary' onClick={this.setRedirectLogin}>Login</Button>
          </CardActions>
        </Card>
        </MuiThemeProvider>
      </div>
    );
  }
}

export default LoginPage;
