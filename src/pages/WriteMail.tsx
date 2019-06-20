import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import { IconButton, AppBar, Typography } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import Toolbar from '@material-ui/core/Toolbar';
import { createMuiTheme } from '@material-ui/core/styles';
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider';


interface Props {
  updateAddingMail: (event: any) => void;
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
    sendTo: string;
    title: string;
}

class WriteMail extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      message: '',
      sendTo: '',
      title: '',
    };
  }
  storageInfo = event => {
    localStorage.setItem('mail-title', this.state.title);
  }
  /**
   * Handle send text field  */ 
  handleChangeSendTo = event => {
    this.setState({
      sendTo: event.target.value,
    });
  }
  /**
   * Handle message text field */ 
  handleChangeMessage = event => {
    this.setState({
      message: event.target.value,
    });
  }
  /**
   * Handle title text field */ 
  handleChangeTitle = event => {
    this.setState({
      title: event.target.value,
    });
  }


  render() {
    const enabled = this.state.title.length > 0;
    return (
      <MuiThemeProvider theme={theme}>     
      <Card className='writemail-card'>
      <AppBar className='writemail-appbar' position='static' color='primary'>
          <CardContent>
          <Toolbar>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updateAddingMail}>
                <CloseIcon />
          </IconButton>
          <Typography variant='h6' color='secondary'>
                WriteMail
            </Typography>
          </Toolbar>
            <TextField
              variant='filled'
              id='sendTo'
              label='Send to'
              margin='normal'
              value={this.state.sendTo}
              onChange={this.handleChangeSendTo}
            />
            <TextField
              variant='filled'
              id='title'
              label='Title'
              margin='normal'
              value={this.state.title}
              onChange={this.handleChangeTitle}
            />
            <TextField
              variant='filled'
              id='message'
              label='Message'
              margin='normal'
              value={this.state.message}
              onChange={this.handleChangeMessage}
            />           
          </CardContent>
          <CardActions>
          <div>
              <Button onClick={this.storageInfo} disabled={!enabled} variant='contained'>Send</Button>
            </div>
          </CardActions>
          </AppBar>
        </Card>     
       </MuiThemeProvider>
    );
  }
}

export default WriteMail;
