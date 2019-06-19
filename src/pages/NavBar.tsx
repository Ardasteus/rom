import * as React from 'react';
import * as PropTypes from 'prop-types';
import { createStyles, withStyles, WithStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import AccountCircle from '@material-ui/icons/AccountCircle';
import Switch from '@material-ui/core/Switch';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormGroup from '@material-ui/core/FormGroup';
import MenuItem from '@material-ui/core/MenuItem';
import Menu from '@material-ui/core/Menu';
import Button from '@material-ui/core/Button';
import { Redirect } from 'react-router-dom';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Dialog from '@material-ui/core/Dialog';
import ListItemText from '@material-ui/core/ListItemText';
import ListItem from '@material-ui/core/ListItem';
import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import CloseIcon from '@material-ui/icons/Close';
import Slide from '@material-ui/core/Slide';
import { Transition } from 'react-transition-group';
import PersonIcon from '@material-ui/icons/Person';
import AddIcon from '@material-ui/icons/Add';
import Inbox from './Inbox';
import Chat from './Chat';
import WriteMail from './WriteMail';
import { createMuiTheme } from '@material-ui/core/styles';
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider';
import { ListItemAvatar, Avatar, DialogTitle } from '@material-ui/core';
import PersonalData from './PersonalData';


const accounts = ['username@gmail.com', 'username02@gmail.com'];
const theme = createMuiTheme({
  palette: {
      primary: {
          main: '#000000',
          light: '#ffffff',
      },
      secondary: {
          main: '#b71c1c',
      },
  },
});

const styles = createStyles({
  root: {
    flexGrow: 1,
  },
  grow: {
    flexGrow: 1,
  },
  menuButton: {
    marginLeft: -12,
    marginRight: 20,
  },
  appBar: {
    position: 'relative',
    backgroundColor: 'black',
    Color: 'white',
  },
  flex: {
    flex: 1,
  },
});

export interface Props extends WithStyles<typeof styles> {}

export interface State {
  redirect: any;
  auth: boolean;
  anchorEl: null | HTMLElement;
  value: boolean;
  open: boolean;
  openAcc: boolean;
  settingsAcc: boolean;
  gettingAccSetting: boolean;
}

class NavBar extends React.Component<Props, State> {
  state: State = {
    auth: true,
    anchorEl: null,
    redirect: false,
    value: false,
    open: false,
    openAcc: false,
    settingsAcc: false,
    gettingAccSetting: true,
  };
  TabContainer = (props) => {
    return (
      <Typography component='div' style={{ padding: 8 * 3 }}>
        {props.children}
      </Typography>
    );
  }
  /** 
   * Set declarable redirect to true */ 
  setRedirect = () => {
    this.setState({
      redirect: true,
    });
  }
  /** 
   *If declarable redirect is true, redirect to LoginPage */ 
  loginRedirect = () => {
    if (this.state.redirect) {
      return <Redirect to='/' />;
    }
  }
  /**
   * Tab switching between chat and inbox  */ 
  handleChangeTab = (event, value) => {
    this.setState({ value });
  }
   /** 
   * Opening menu */ 
  handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    this.setState({ anchorEl: event.currentTarget });
  }
   /** 
   * Closing menu */ 
  handleClose = () => {
    this.setState({ anchorEl: null });
  }
  /** 
   * Opens settings dialog */ 
  handleClickOpen = () => {
    this.setState({ open: true });
  }
  /**
   * Close settings dialog */ 
  handleCloseSettings = () => {
    this.setState({ open: false });
  }
  /** 
   * Handle profile dialog, open*/ 
  handleClickOpenAcc = () => {
    this.setState({ openAcc: true });
  }
  /**
   *  Handle profile dialog, false */ 
  handleCloseAcc = () => {
    this.setState({ openAcc: false });
  }
  
  /**
   * Handle PersonalData component in settings  */  
  ShowingPersonalData = () => {
    if (this.state.settingsAcc === true) {
      return <PersonalData updatePersonalData={this.updatePersonalData} />;
    }
  }
  /**
   *  Handle if acc.settings, true */ 
  PersDataopen = () => {
    this.setState({
      settingsAcc: true,
    });
  }
  /**
   * Handle if acc.settings, false */ 
  updatePersonalData = (event: any) => {
    this.setState({
      settingsAcc: false,
    });
  }

  render() {
    const { classes } = this.props;
    const { auth, anchorEl } = this.state;
    const open = Boolean(anchorEl);
    const { value } = this.state;

    return (
      <div className={classes.root}>
        <MuiThemeProvider theme={theme}>
        <AppBar position='static' color='primary'>
        <Dialog
          fullScreen
          open={this.state.open}
          onClose={this.handleCloseSettings}
          TransitionComponent={Transition}
        >
          <AppBar className={classes.appBar} color='primary'>
            <Toolbar>
              <IconButton color='secondary'  onClick={this.handleCloseSettings} aria-label='Close'>
                <CloseIcon />
              </IconButton>
              <Typography variant='h6' color='secondary'className={classes.flex}>
                Settings
              </Typography>
              <Button color='secondary'  onClick={this.handleCloseSettings}>
                Save
              </Button>
            </Toolbar>
          </AppBar>         
          <List>
            <ListItem button>
              <ListItemText primary='Dashboard'/>
            </ListItem>
            <ListItem button onClick={this.PersDataopen}>
              <ListItemText primary='Personal data'/>
            </ListItem>

            <ListItem button>
              <ListItemText primary='Data and personalisation'/>
            </ListItem>

            <ListItem button>
              <ListItemText primary='Security'/>
            </ListItem>

            <ListItem button>
              <ListItemText primary='People and sharing'/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary='Send feedback'/>
            </ListItem>
            <ListItem button>
              <ListItemText primary='Report bugs'/>
            </ListItem>
          </List>
          {this.ShowingPersonalData()}       
        </Dialog>
      <Dialog open={this.state.openAcc} onClose={this.handleCloseAcc} aria-labelledby='account-dialog'>
      <DialogTitle id='account-dialog'>Switch account</DialogTitle>
      <List>
        {accounts.map(account => (
          <ListItem button key={account}>
            <ListItemAvatar>
              <Avatar>
                <PersonIcon />
              </Avatar>
            </ListItemAvatar>
            <ListItemText primary={account} />
          </ListItem>
        ))}
        <ListItem button >
          <ListItemAvatar>
            <Avatar>
              <AddIcon />
            </Avatar>
          </ListItemAvatar>
          <ListItemText primary='add account' />
        </ListItem>
      </List>
    </Dialog>
          <AppBar className='header'>
            <Typography variant='h6' color='secondary' className={classes.grow}>
              Ruby On Mails
              <Tabs value={value} onChange={this.handleChangeTab}>
               <Tab label='Inbox' />
               <Tab label='Chat' />
              </Tabs>
              {auth && (
              <div className='AccountCircle'>
                <IconButton
                  aria-owns={open ? 'menu-appbar' : undefined}
                  aria-haspopup='true'
                  onClick={this.handleMenu}
                  color='secondary'
                >
                  <AccountCircle />
                </IconButton>
                <Menu
                  id='menu-appbar'
                  anchorEl={anchorEl}
                  anchorOrigin={{
                    vertical: 'top',
                    horizontal: 'right',
                  }}
                  transformOrigin={{
                    vertical: 'top',
                    horizontal: 'right',
                  }}
                  open={open}
                  onClose={this.handleClose}
                >
                  {this.loginRedirect()}
                  <MenuItem  onClick={this.handleClickOpenAcc}>Profile</MenuItem>
                  <MenuItem  onClick={this.handleClickOpen}>Settings</MenuItem>
                  <MenuItem  onClick={this.setRedirect}>Logout</MenuItem>
                </Menu>
              </div>
            )}
            </Typography>
          </AppBar>
        </AppBar>
        {value == false && <this.TabContainer><Inbox /></this.TabContainer>}
        {value == true && <this.TabContainer><Chat /></this.TabContainer>}
        </MuiThemeProvider>
      </div>
    );
  }
}

(NavBar as React.ComponentClass<Props>).propTypes = {
  classes: PropTypes.object.isRequired,
} as any;

export default withStyles(styles)(NavBar);
