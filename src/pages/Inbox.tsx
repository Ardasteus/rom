import * as React from 'react';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import Button from '@material-ui/core/Button';
import Fab from '@material-ui/core/Fab';
import AddIcon from '@material-ui/icons/Add';
import { Card, CardContent, CardActions } from '@material-ui/core';
import WriteMail from './WriteMail';
import Mail from './Mail';

class Inbox extends React.Component {
  state: {
    addingMail: boolean,
    selectedInbox: string
  };
  newMailWrite = () => {
    this.setState({
      addingMail: true,
    });
  }
  MailWriting = () => {
    if (this.state.addingMail == true) {
      return <WriteMail />;
    }
  }

  render() {
    return (
      <div>
      <Card className="inbox">
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
               <AddIcon />
             </Fab>
        </div>  
      </div>
      
    );
  }
}

export default Inbox;
