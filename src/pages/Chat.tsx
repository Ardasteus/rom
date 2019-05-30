import * as React from 'react';
import { Card, CardHeader, Divider, CardContent } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import AccountCircle from '@material-ui/icons/AccountCircle';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import IconButton from '@material-ui/core/IconButton';

class Chat extends React.Component {
  render() {
    return (
    <div>
      <Card className="personChat">
        <CardHeader>
          <IconButton>
          <AccountCircle />
          </IconButton>          
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
      <Card className="chat-menu">
        <CardContent>
          <List>
          <ListItem button>
              
            </ListItem>
            <Divider />
            <ListItem button>
              
            </ListItem>
          </List>         
        </CardContent>
      </Card>
    </div>
    );
  }
}

export default Chat;
