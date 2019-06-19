import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import { IconButton } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';


interface Props {
  updateAddingMail: (event: any) => void;
}

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
    return (
    <div>
      <Card className='writemail-card'>
          <CardContent>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updateAddingMail}>
                <CloseIcon />
          </IconButton>
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
            <div>
              <Button variant='contained'>Send</Button>
            </div>
          </CardContent>
          <CardActions>
            
          </CardActions>
        </Card>
       </div>
    );
  }
}

export default WriteMail;
