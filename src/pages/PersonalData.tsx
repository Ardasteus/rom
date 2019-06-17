import * as React from 'react';
import { AppBar, Dialog, Toolbar, IconButton, Typography, Button, CardContent, Card, TextField, DialogActions, DialogContentText, DialogContent, DialogTitle } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import axios from 'classes/axios.instance';

interface Props {
  updatePersonalData: (event: any) => void;
}

const Namedata = []
const Password = []

export interface State {
  message: string;
  gettingNameData: boolean;
  gettingPasswordData: boolean;
  open: boolean;
  newPassword: string;
  oldPassword: string;
}

class PersonalData extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      message: '',
      gettingNameData: true,
      gettingPasswordData: false,
      open: false,
      newPassword: '123456',
      oldPassword: 'Aa0123456',
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
      Namedata.splice(0,1) 
      Namedata.push(response.data.name)  
      console.log(Namedata)
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

//  handleChange = name => event => {
//    this.setState({
//      [name]: event.target.value,
//    });
//  }


  handleOpenTrue = () => {
    this.setState({ open: true });
  }

  handleOpenFalse = () => {
    this.setState({gettingPasswordData: true});
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
            />
            <TextField 
              variant='outlined'
              color='secondary'
              id='newpassword'
              type='password'
              label='New Password'
              margin='normal'
              value={this.state.newPassword}
            />
          </DialogContent>
          <DialogActions>
          {this.getPasswordData()}
            <Button onClick={this.handleOpenFalse} color='primary' autoFocus>
              Ok
            </Button>
          </DialogActions>
        </Dialog>
      <Card className='personal-card'>
          <CardContent>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updatePersonalData}>
                <CloseIcon />
          </IconButton>
            <h2>Name : {Namedata}</h2>
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
