import * as React from 'react';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import Button from '@material-ui/core/Button';
import Fab from '@material-ui/core/Fab';
import AddIcon from '@material-ui/icons/Add';
import { Card, CardContent, CardActions, CardHeader, Paper } from '@material-ui/core';
import WriteMail from './WriteMail';
import DeleteIcon from '@material-ui/icons/Delete';
import DeleteRoundedIcon from '@material-ui/icons/DeleteRounded';
import DeleteForeverRoundedIcon from '@material-ui/icons/DeleteForeverRounded';
import Mail from './Mail';
import Checkbox from '@material-ui/core/Checkbox';
import CloseIcon from '@material-ui/icons/Close';
import ShowMail from './ShowMail';

interface State {
  addingMail: boolean;
  showingMail: boolean;
  sentMail: boolean;
  text: string;
}

class Inbox extends React.Component<{}, State> {
  constructor(props) {
    super(props);
    this.state = { 
      addingMail: false, 
      showingMail: false,
      sentMail: false,
     // mails: [],
      text: 'TODO: Mails',
    };
  }


  // Sets declarable addingMail true
  newMailWrite = () => {
    this.setState({
      addingMail: true,
    });
  }

  updateAddingMail = (event: any) => {
    this.setState({
      addingMail: false,
    });
  }
   
  // If declarable addingMail is true, show component WriteMail
  MailWriting = () => {
    if (this.state.addingMail === true) {
      return <WriteMail updateAddingMail={this.updateAddingMail} />;
    }
  }
  
  sendingMail = (event: any) => {
    this.setState({
      sentMail: false,
    });
  }

  SendingMail = () => {
    if (this.state.sentMail === true) {
      
    }
  }

  showingMail = () => {
    if (this.state.showingMail === true) {
      return <ShowMail updateShowingMail={this.updateShowingMail} />;
    }
  }

  updateShowingMail = (event: any) => {
    this.setState({
      showingMail: false,
    });
  }

  newShowMail = () => {
    this.setState({
      showingMail: true,
    });
  }

  render() {
    return (
      <div>     
        
        <Paper className='inbox' style={{maxHeight: 200, overflow: 'auto'}}>        
           <List>
           <ListItem button onClick={this.newShowMail}>
              <ListItemText primary={this.state.text}/>
            </ListItem>
            <Divider/>
            <ListItem button>
              <ListItemText primary={this.state.text}/> 
            </ListItem>
            <Divider/>
            <ListItem button>
              <ListItemText primary={this.state.text}/>
            </ListItem>
            <Divider/>
            <ListItem button>
              <ListItemText primary={this.state.text}/>
            </ListItem>
           </List>
        </Paper>
        {this.showingMail()}   
        <Card className='inbox-menu'>
          <CardContent>
          <List>
            <ListItem button>
              <ListItemText primary='Inbox'/>
            </ListItem>
            <Divider/>
            <ListItem button>
              <ListItemText primary='Spam'/>
            </ListItem>
            <Divider/>
            <ListItem button>
              <ListItemText primary='Drafts'/>
            </ListItem>
          </List>
          </CardContent>
        </Card>
        <div className='writeMailButton'>
           {this.MailWriting()}
             <Fab color='primary' aria-label='Add' onClick={this.newMailWrite}>
               <AddIcon/>
             </Fab>
        </div>

      </div>

    );
  }
}

export default Inbox;
