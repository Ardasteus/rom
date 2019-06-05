import * as React from 'react';
import { Card, CardHeader, Divider, CardContent, Paper, CardActions, Button } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import AccountCircle from '@material-ui/icons/AccountCircle';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import IconButton from '@material-ui/core/IconButton';

class Chat extends React.Component {
  state = {
    message: ''
  };
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }
  sendMessage = () => event => {
    this.setState({
      [name]: event.target.value,
    });
  }

  render() {
    const { message } = this.state;
    return (
    <div>
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
          value={this.state.message}
          onChange={this.handleChange('message')}
          fullWidth>
        </TextField>
        </CardContent> 
        <CardActions className='sendButton'>
          <Button  onClick={this.sendMessage}>Send</Button>
        </CardActions>      
      </Card>
      <Card className='chat-menu'>
        <CardContent>
        <Paper style={{maxHeight: 200, overflow: 'auto'}}>
           <List>
           <ListItem button>
             <ListItemIcon>
               <AccountCircle />
             </ListItemIcon>
              <ListItemText primary='John Generic'/>
            </ListItem>
            <ListItem button>
             <ListItemIcon>
               <AccountCircle />
             </ListItemIcon>
              <ListItemText primary='John Generic'/>
            </ListItem>           
            <ListItem button>
             <ListItemIcon>
               <AccountCircle />
             </ListItemIcon>
              <ListItemText primary='John Generic'/>
            </ListItem>
           </List>
        </Paper>
        </CardContent>
      </Card>
    </div>
    );
  }
}

export default Chat;
