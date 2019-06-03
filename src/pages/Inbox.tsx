import * as React from 'react';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import Button from '@material-ui/core/Button';
import Fab from '@material-ui/core/Fab';
import AddIcon from '@material-ui/icons/Add';
import { Card, CardContent, CardActions, CardHeader } from '@material-ui/core';
import WriteMail from './WriteMail';
import DeleteIcon from '@material-ui/icons/Delete';
import DeleteRoundedIcon from '@material-ui/icons/DeleteRounded';
import DeleteForeverRoundedIcon from '@material-ui/icons/DeleteForeverRounded';
import Mail from './Mail';
import Checkbox from '@material-ui/core/Checkbox';

export interface State {
  addingMail: boolean,
  selectedInbox: string
}

class Inbox extends React.Component {
  state: State = {
    addingMail: false,
    selectedInbox: "Inbox"
  }
  
  // Sets declarable addingMail true
  newMailWrite = () => {
    this.setState({
      addingMail: true,
    });
  }
  // If declarable addingMail is true, show component WriteMail
  MailWriting = (props) => {
    if (this.state.addingMail == true) {
      return <WriteMail/>;
    }
  }
  

  render() {
    return (
      <div>
      <Card className="inbox">
        <CardHeader>
          selectedInbox
        </CardHeader>
        <CardContent>   
           <List>
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary=""/>
            </ListItem>
            <Divider />
          </List>        
        </CardContent>  
        </Card>  
        <Card className="inbox-menu">
          <CardContent>
          <List>
            <ListItem button>
              <ListItemText primary="Inbox"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="Spam"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="Drafts"/>
            </ListItem>
          </List>
          </CardContent>
        </Card> 
        <div className="writeMailButton">         
             <Fab color="primary" aria-label="Add" onClick={this.newMailWrite} >
               <AddIcon/>
             </Fab>       
        </div>  
      </div>
      
    );
  }
}

export default Inbox;
