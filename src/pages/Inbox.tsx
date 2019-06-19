import * as React from 'react';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Button from '@material-ui/core/Button';
import Fab from '@material-ui/core/Fab';
import AddIcon from '@material-ui/icons/Add';
import { Card, CardContent, CardActions, CardHeader, Paper, TextField, DialogActions, DialogContent, Dialog, DialogTitle } from '@material-ui/core';
import WriteMail from './WriteMail';
import DeleteIcon from '@material-ui/icons/Delete';
import ShowMail from './ShowMail';
import axios from 'classes/axios.instance';


const emails = ['Email01', 'Email02', 'Email03', 'Email04', 'Email05'];


interface State {
  addingMail: boolean;
  showingMail: boolean;
  sentMail: boolean;
  text: string;
  gettingCollections: boolean;
  open: boolean;
  openDel: boolean;
  newCollection: string;
  gettingNewCollection: boolean;
  deletingCollection: boolean;
  deleteCollection: string;
  collectionData: Array<string>;
}

class Inbox extends React.Component<{}, State> {
  constructor(props) {
    super(props);
    this.state = {
      addingMail: false,
      showingMail: false,
      sentMail: false,
      text: 'TODO: Mails',
      gettingCollections: true,
      open: false,
      openDel: false,
      newCollection: '',
      gettingNewCollection: false,
      deletingCollection: false,
      deleteCollection: '',
      collectionData: []
    };

  }


  /**
   * Sets state addingMail true */ 
  newMailWrite = () => {
    this.setState({
      addingMail: true,
    });
  }
  /**
   * Sets state addingMail false
   */
  updateAddingMail = (event: any) => {
    this.setState({
      addingMail: false,
    });
  }

  /**
   * If state addingMail is true, show component WriteMail */ 
  MailWriting = () => {
    if (this.state.addingMail === true) {
      return <WriteMail updateAddingMail={this.updateAddingMail} />;
    }
  }
  /**
   * Set state sentMail to false
   */
  sendingMail = (event: any) => {
    this.setState({
      sentMail: false,
    });
  }

  /**
   * If state showingMail is true, return component ShowMail
   */
  showingMail = () => {
    if (this.state.showingMail === true) {
      return <ShowMail updateShowingMail={this.updateShowingMail} />;
    }
  }
  /**
   * Set state showingMail to false
   */
  updateShowingMail = (event: any) => {
    this.setState({
      showingMail: false,
    });
  }
  /**
   * Set state showingMail to true
   */
  newShowMail = () => {
    this.setState({
      showingMail: true,
    });
  }
  /**
   * Get list of collections from API
   */
  getCollections = () => {
    if(this.state.gettingCollections){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token}
  };  
    axios.get('mails', config)
    .then(response => {
      console.log(response) 
      this.setState({
        collectionData: this.state.collectionData.concat(response.data.items)
      })
      console.log(this.state.collectionData)
      }
    )
    this.setState({gettingCollections: false});
    }   
  }
  /**
   * Gets token from localstorage, posts new collection to API by sending Create collection dialog text field value
   */
  newCollections = () => {
    if(this.state.gettingNewCollection){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token , 'Content-Type': 'application/json'}
  };  
    axios.post('mails/' + this.state.newCollection, null, config)
    .then(response => {
      console.log(response) 
      }
    )
    this.setState({gettingNewCollection: false});
    }   
  }
  /**
   * Gets token from localstorage, deletes a collection to API by sending Delete collection dialog text field value
   */
  deleteCollections = () => {
    if(this.state.deletingCollection){
    const token = localStorage.getItem('token');   
    console.log(token) 
    var config = {
      headers: {'Authorization': "Bearer " + token , 'Content-Type': 'application/json'}
  };  
    axios.delete('mails/' + this.state.deleteCollection, config)
    .then(response => {
      console.log(response) 
      }
    )
    this.setState({deletingCollection: false});
    }   
  }

  /**
   * Set state open to true -} open Create collection dialog
   */
  handleOpenTrue = () => {
    this.setState({ open: true });
  }
  /**
   * Set state openDel to true -} open Delete a collection dialog
   */
  handleOpenTrueDel = () => {
    this.setState({ openDel: true });
  }

  /**
   * Handle OK button in Create collection dialog, sets state gettingNewCollection true, which sends text field value to API, then sets state open false, which closes the dialog
   */
  handleOpenFalseConfirm = () => {
    this.setState({gettingNewCollection: true});
    this.setState({ open: false });
  }
  /**
   * Handle OK button in Delete a collection dialog, sets state deletingCollection true, which sends text field value to API, then sets state open false, which closes the dialog
   */
  handleOpenFalseDelConfirm = () => {
    this.setState({deletingCollection: true});
    this.setState({ openDel: false });
  }
  /**
   * Set state open to false, closing Create collection dialog
   */
  handleOpenFalse = () => {
    this.setState({ open: false });
  }
  /**
   * Set state openDel to false, closing Delete a collection dialog
   */
  handleOpenFalseDel = () => {
    this.setState({ openDel: false });
  }
  /**
   * Handles change in Create collection dialogs text field
   */
  handleChangeCollection = event => {
    this.setState({
      newCollection: event.target.value,
    });
  }
  /**
   * Handles change in Delete a collection dialogs text field
   */
  handleChangeDelCollection = event => {
    this.setState({
      deleteCollection: event.target.value,
    });
  }

  render() {
    return (
      <div>
        {this.newCollections()}
        {this.getCollections()} 
        {this.deleteCollections()} 
        <Dialog
          open={this.state.open}
          aria-labelledby='alert-dialog-title'
          aria-describedby='alert-dialog-description'
        >
          <DialogTitle id='alert-dialog-title'>{'Create a collection'}</DialogTitle>
          <DialogContent>
          <TextField 
              variant='outlined'
              color='secondary'
              id='collection'
              label='New Collection'
              margin='normal'
              value={this.state.newCollection}
              onChange={this.handleChangeCollection}
            />

          </DialogContent>
          <DialogActions>

            <Button onClick={this.handleOpenFalseConfirm} color='primary' autoFocus>
              Ok
            </Button>
            <Button onClick={this.handleOpenFalse} color='primary' autoFocus>
              Cancel
            </Button>
          </DialogActions>
        </Dialog>
        <Dialog
          open={this.state.openDel}
          aria-labelledby='alert-dialog-title-del'
          aria-describedby='alert-dialog-description-del'
        >
          <DialogTitle id='alert-dialog-title-del'>{'Delete a collection'}</DialogTitle>
          <DialogContent>
          <TextField 
              variant='outlined'
              color='secondary'
              id='collection-del'
              label='Collection to delete'
              margin='normal'
              value={this.state.deleteCollection}
              onChange={this.handleChangeDelCollection}
            />

          </DialogContent>
          <DialogActions>

            <Button onClick={this.handleOpenFalseDelConfirm} color='primary' autoFocus>
              Ok
            </Button>
            <Button onClick={this.handleOpenFalseDel} color='primary' autoFocus>
              Cancel
            </Button>
          </DialogActions>
        </Dialog>       
        <Paper className='inbox' style={{maxHeight: 200, overflow: 'auto'}}>
           <List>
           {emails.map(email => (
           <ListItem key={email} button onClick={this.newShowMail}>
              <ListItemText primary={email}/>
            </ListItem>
            ))}
           </List>
        </Paper>
        {this.showingMail()}
        
        <Card className='inbox-menu'>
          <CardContent>
          <List>
          {this.state.collectionData.map((cocdata: any) => {
            <ListItem key={cocdata} button>
            <ListItemText primary={cocdata.name}/>
          </ListItem>
          })}
            <ListItem button  onClick={this.handleOpenTrue}>
              <AddIcon />
          <ListItemText primary='add collection' />
        </ListItem>

        <ListItem button  onClick={this.handleOpenTrueDel}>
              <DeleteIcon />
          <ListItemText primary='remove collection' />
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
