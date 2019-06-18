import * as React from 'react';
import { AppBar, Dialog, Toolbar, IconButton, Typography, Button, CardContent, Card, TextField, DialogActions, DialogContentText, DialogContent, DialogTitle } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import axios from 'classes/axios.instance';

interface Props {
  updatePersonalData: (event: any) => void;
}

const Namedata = []

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



  handleChangeOldPass = event => {
    this.setState({
      oldPassword: event.target.value,
    });
  }

  handleChangeNewPass = event => {
    this.setState({
      newPassword: event.target.value,
    });
  }

  handleOpenTrue = () => {
    this.setState({ open: true });
  }

  handleOpenFalseConfirm = () => {
    this.setState({gettingPasswordChanging: true});
    this.setState({gettingPasswordData: true});
    this.setState({ open: false });
  }
  handleOpenFalse = () => {
    this.setState({ open: false });
  }

  render() {
    return (
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
          
    );
  }
}

export default PersonalData;
