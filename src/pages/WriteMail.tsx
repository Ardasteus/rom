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

class WriteMail extends React.Component<Props, {}> {
  constructor(props: Props) {
    super(props);
    this.state = {
      message: '',
    };
  }

  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }

  closeMailWrite = () => {
    this.setState({
      addingMail: false,
    });
  }
  render() {
  //  const { message } = this.state;
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
         //     value={this.state.message}
              onChange={this.handleChange('message')}
            />
            <div>
              <Button variant='contained'>Send</Button>
            </div>
          </CardContent>
        </Card>
       </div>
    );
  }
}

export default WriteMail;
