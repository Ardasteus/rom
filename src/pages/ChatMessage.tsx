import * as React from 'react';
import { CardContent, Card, Divider, TextField, CardActions, Button } from '@material-ui/core';

interface Props {
  updateShowingMessage: (event: any) => void;
}

class ChatMessage extends React.Component<Props, {}> {
  constructor(props: Props) {
    super(props);
  }

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
          variant='outlined'
          margin='normal'
          fullWidth>
        </TextField>
        </CardContent>
        <div className='sendButton'>
          <Button variant='contained' onClick={this.props.updateShowingMessage} >Send</Button>
        </div>
      </Card>
    );
  }
}

export default ChatMessage;
