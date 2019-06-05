import * as React from 'react';
import { Card, CardHeader, Divider, CardContent, Paper, CardActions, Button } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import AccountCircle from '@material-ui/icons/AccountCircle';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import IconButton from '@material-ui/core/IconButton';
import ChatMessage from './ChatMessage';

class Chat extends React.Component {
  state = {
    message: '',
    showingMessage: false
  };
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }
  showMessage = () => {
    if (this.state.showingMessage === true) {
      return <ChatMessage updateShowingMessage={this.updateShowingMessage} />;
    }
  }
  updateShowingMessage = (event: any) => {
    this.setState({
      showingMessage: false,
    });
  }
  showingMessage = () => {
    this.setState({
      showingMessage: true,
    });
  }

  render() {
    const { message } = this.state;
    return (
    <div>
        <Paper className='chat-menu' style={{maxHeight: 200, overflow: 'auto'}}>
           <List>
           <ListItem button onClick={this.showingMessage}>
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
        {this.showMessage()}
    </div>
    );
  }
}

export default Chat;
