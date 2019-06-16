import * as React from 'react';
import { AppBar, Dialog, Toolbar, IconButton, Typography, Button, CardContent, Card, TextField } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import axios from 'classes/axios.instance';

interface Props {
  updatePersonalData: (event: any) => void;
}

export interface State {
  message: string;
  gettingData: boolean;
}

class PersonalData extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      message: '',
      gettingData: true,
    };
  }

  getData = () => {
    if(this.state.gettingData){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token}
  };  
    axios.get('me', config)
    .then(response => {
      console.log(response)     
      }
    )
    this.setState({gettingData: false});
    }   
  }

  render() {
    return (
      <div>
        {this.getData()}
      <Card className='personal-card'>
          <CardContent>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updatePersonalData}>
                <CloseIcon />
          </IconButton>

            <TextField
              variant='filled'
              id='sendTo'
              label='Send to'
              margin='normal'
            />
            <TextField
              variant='filled'
              id='title'
              label='Title'
              margin='normal'
            />
            <TextField
              variant='filled'
              id='message'
              label='Message'
              margin='normal'                      
            />
            <div className='Change-pass'>
              <Button variant='contained'>Change password</Button>
            </div>
          </CardContent>
        </Card>
       </div>
          
    );
  }
}

export default PersonalData;
