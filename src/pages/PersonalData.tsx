import * as React from 'react';
import { AppBar, Dialog, Toolbar, IconButton, Typography, Button, CardContent, Card, TextField, DialogActions, DialogContentText, DialogContent, DialogTitle } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import axios from 'classes/axios.instance';
import { createMuiTheme } from '@material-ui/core/styles';
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider';

interface Props {
  updatePersonalData: (event: any) => void;
}

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


export interface State {
  message: string;
  gettingNameData: boolean;
  gettingPasswordData: boolean;
  gettingPasswordChanging: boolean;
  open: boolean;
  newPassword: string;
  oldPassword: string;
  namedata: string;
}

class PersonalData extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      message: '',
      gettingNameData: true,
      gettingPasswordData: false,
      gettingPasswordChanging: false,
      open: false,
      newPassword: '',
      oldPassword: '',
      namedata: '',
    };
  }
  /**
   * Get token from localstorage, get list of Me info from API */ 
  getNameData = () => {
    if(this.state.gettingNameData){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token}
  };  
    axios.get('me', config)
    .then(response => {
      console.log(response) 
      this.setState({
        namedata: this.state.namedata.concat(response.data.name)
      })
      console.log(this.state.namedata)   
      }
    )
    this.setState({gettingNameData: false});
    }   
  }

  /**
   * Get token from localstorage, on press of OK in change password dialog in personal data, post old password and new password to api */ 
  getPasswordData = () => {
    if(this.state.gettingPasswordData){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token}
  };  
    axios.post('me/password',{old: this.state.oldPassword,new: this.state.newPassword}, config)
    .then(response => {
      console.log(response)   
      }
    )
    this.setState({gettingPasswordData: false});
    }   
  }
  /**
   * Get token from localstorage, on press of OK in change password dialog in personal data, get if user can change password */ 
  getPasswordChanging = () => {
    if(this.state.gettingPasswordChanging){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token}
  };  
    axios.get('me/has_password', config)
    .then(response => {
      console.log(response)   
      }
    )
    this.setState({gettingPasswordChanging: false});
    }   
  }


  /**
   * handle old password text field */ 
  handleChangeOldPass = event => {
    this.setState({
      oldPassword: event.target.value,
    });
  }
  /**
   * handle new password text field */ 
  handleChangeNewPass = event => {
    this.setState({
      newPassword: event.target.value,
    });
  }
  /**
   * set state open to true, opens dialog personal data */ 
  handleOpenTrue = () => {
    this.setState({ open: true });
  }
  /**
   * handle OK button in Personal data change password dialog  */ 
  handleOpenFalseConfirm = () => {
    this.setState({gettingPasswordChanging: true});
    this.setState({gettingPasswordData: true});
    this.setState({ open: false });
  }
  /**
   * handle Cancel button in Personal data change password dialog */ 
  handleOpenFalse = () => {
    this.setState({ open: false });
  }

  render() {
    return (
      <MuiThemeProvider theme={theme}>  
      <div>
        {this.getNameData()}
        <Dialog
          open={this.state.open}
          aria-labelledby='alert-dialog-title'
          aria-describedby='alert-dialog-description'
        >
          <DialogTitle id='alert-dialog-title'>{'Change your password'}</DialogTitle>
          <DialogContent>
          <TextField 
              variant='outlined'
              color='secondary'
              id='oldpassword'
              type='password'
              label='Old Password'
              margin='normal'
              value={this.state.oldPassword}
              onChange={this.handleChangeOldPass}
            />
            <TextField 
              variant='outlined'
              color='secondary'
              id='newpassword'
              type='password'
              label='New Password'
              margin='normal'
              value={this.state.newPassword}
              onChange={this.handleChangeNewPass}
            />
          </DialogContent>
          <DialogActions>
          {this.getPasswordData()}
          {this.getPasswordChanging()}
            <Button onClick={this.handleOpenFalseConfirm} color='primary' autoFocus>
              Ok
            </Button>
            <Button onClick={this.handleOpenFalse} color='primary' autoFocus>
              Cancel
            </Button>
          </DialogActions>
        </Dialog>
      <Card className='personal-card'>
      <AppBar className='collection-appbar' position='static' color='primary'>
           <Toolbar>
           <Typography variant='h6' color='secondary'>
                Personal Data
            </Typography>
           </Toolbar>
            </AppBar>
          <CardContent>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updatePersonalData}>
                <CloseIcon />
          </IconButton>
            <h2>Name : {this.state.namedata}</h2>
            <div className='Change-pass'>
              <Button variant='contained' onClick={this.handleOpenTrue}>Change password</Button>
            </div>
          </CardContent>
        </Card>
       </div>
       </MuiThemeProvider>            
    );
  }
}

export default PersonalData;
