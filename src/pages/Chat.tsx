import * as React from 'react';
import { Card, CardHeader, Divider, CardContent, Paper, CardActions, Button, ListItemAvatar, Avatar } from '@material-ui/core';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import ChatMessage from './ChatMessage';
import PersonIcon from '@material-ui/icons/Person';

const contacts = ['John generic', 'Roman Spanko', 'Matyas Pokorny'];

class Chat extends React.Component {
  state = {
    message: '',
    showingMessage: false,
  };
  /**
   * Handles change of text fields
   */
  handleChange = name => event => {
    this.setState({
      [name]: event.target.value,
    });
  }
  /**
   * If state showingMessage is true, return component ChatMessage
   */
  isShowingMessage = () => {
    if (this.state.showingMessage === true) {
      return <ChatMessage updateShowingMessage={this.updateShowingMessage} />;
    }
  }
  /**
   * Set state showingMessage false, closing ChatMessage
   */
  updateShowingMessage = (event: any) => {
    this.setState({
      showingMessage: false,
    });
  }
  /**
   * Set state showingMessage true, opening ChatMessage
   */
  showMessage = () => {
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
           <ListItem key={contact} button onClick={this.showMessage}>
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
        {this.isShowingMessage()}
    </div>
    );
  }
}

export default Chat;
