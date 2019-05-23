import * as React from 'react';
import { Card, CardHeader, Divider, CardContent } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';

class Chat extends React.Component {
  render() {
    return (
    <div className="personChat">
      <Card>
        <CardHeader>
          PersonName
        </CardHeader>
        <Divider/>
        <CardContent>
          Message
        </CardContent>
        <Divider/>
        <TextField>
           id='message'
           label='Message'
           margin='normal'
        </TextField>
      </Card>
    </div>
    );
  }
}

export default Chat;
