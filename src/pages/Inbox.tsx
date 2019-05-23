import * as React from 'react';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import Button from '@material-ui/core/Button';
import Fab from '@material-ui/core/Fab';
import AddIcon from '@material-ui/icons/Add';
import WriteMail from './WriteMail';
import Mail from './Mail';

class Inbox extends React.Component {
  state: {
    addingMail: false
  };
  newMailWrite = () => {
    this.setState({
      addingMail: true,
    });
  }
  MailWriting = () => {
    if (this.state.addingMail) {
      return <WriteMail />;
    }
  }

  render() {
    return (
      <div className="inbox">     
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
