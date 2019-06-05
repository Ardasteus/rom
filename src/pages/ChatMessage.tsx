import * as React from 'react';
import { CardContent, Card, Divider, TextField, CardActions, Button } from '@material-ui/core';

class ChatMessage extends React.Component {
  render() {
    return (
      <Card className='personChat'>
        <CardContent>
          John Generic
          <Divider/>
          this.state.message
          <Divider/>
          <TextField
          id='message'
          label='Message'
          variant="outlined"
          margin='normal'
          fullWidth>
        </TextField>
        </CardContent> 
        <CardActions className='sendButton'>
          <Button >Send</Button>
        </CardActions>      
      </Card>
    );
  }
}

export default ChatMessage;
