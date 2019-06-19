import * as React from 'react';
import { Card, CardHeader, Divider, CardContent, Paper, CardActions, Button, ListItemAvatar, Avatar } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import AccountCircle from '@material-ui/icons/AccountCircle';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import IconButton from '@material-ui/core/IconButton';
import ChatMessage from './ChatMessage';
import PersonIcon from '@material-ui/icons/Person';
import { ThemeProvider } from '@livechat/ui-kit'

const contacts = ['John generic', 'Roman Spanko', 'Matyas Pokorny'];

class Chat extends React.Component {
  state = {
    message: '',
    showingMessage: false,
  };
  // Handle change of textfields
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }
  // Handle Chatmessage component
  showMessage = () => {
    if (this.state.showingMessage === true) {
      return <ChatMessage updateShowingMessage={this.updateShowingMessage} />;
    }
  }
  // Set state showingMessage false
  updateShowingMessage = (event: any) => {
    this.setState({
      showingMessage: false,
    });
  }
  // Set state showingMessage true
  showingMessage = () => {
    this.setState({
      showingMessage: true,
    });
  }

  render() {
    return (
    <div>
        <Paper className='chat-menu' style={{maxHeight: 200, overflow: 'auto'}}>
           <List>
           {contacts.map(contact => (
           <ListItem key={contact} button onClick={this.showingMessage}>
             <ListItemIcon>
             <ListItemAvatar>
              <Avatar>
                <PersonIcon />
              </Avatar>
            </ListItemAvatar>
             </ListItemIcon>
              <ListItemText  primary={contact}/>
            </ListItem>
            ))}
           </List>
        </Paper>
        {this.showMessage()}
    </div>
    );
  }
}

export default Chat;
