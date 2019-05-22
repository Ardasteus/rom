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
import Inbox from './Inbox';
import Chat from './Chat';

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
}

class NavBar extends React.Component<Props, State> {
  state: State = {
    auth: true,
    anchorEl: null,
    redirect: false,
    value: false,
    open: false
  };
  TabContainer = (props) => {
    return (
      <Typography component="div" style={{ padding: 8 * 3 }}>
        {props.children}
      </Typography>
    );
  }
  setRedirect = () => {
    this.setState({
      redirect: true,
    });
  }
  loginRedirect = () => {
    if (this.state.redirect) {
      return <Redirect to='/' />;
    }
  }

  handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    this.setState({ auth: event.target.checked });
  }
  handleChange1 = (event, value) => {
    this.setState({ value });
  }

  handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    this.setState({ anchorEl: event.currentTarget });
  }

  handleClose = () => {
    this.setState({ anchorEl: null });
  }
  handleClickOpen = () => {
    this.setState({ open: true });
  };
  
  handleClose1 = () => {
    this.setState({ open: false });
  };

  render() {
    const { classes } = this.props;
    const { auth, anchorEl } = this.state;
    const open = Boolean(anchorEl);
    const { value } = this.state;

    return (
      <div className={classes.root}>
        <AppBar position='static'>
        <Dialog
          fullScreen
          open={this.state.open}
          onClose={this.handleClose1}
          TransitionComponent={Transition}
        >
          <AppBar className={classes.appBar}>
            <Toolbar>
              <IconButton color="inherit" onClick={this.handleClose1} aria-label="Close">
                <CloseIcon />
              </IconButton>
              <Typography variant="h6" color="inherit" className={classes.flex}>
                Settings
              </Typography>
              <Button color="inherit" onClick={this.handleClose1}>
                save
              </Button>
            </Toolbar>
          </AppBar>
          <List>
            <ListItem button>
              <ListItemText primary="Dashboard"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="Personal data"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="Data and personilaziton"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="Security"/>
            </ListItem>
            
            <ListItem button>
              <ListItemText primary="People and sharing"/>
            </ListItem>
            <Divider />
            <ListItem button>
              <ListItemText primary="Send feedback"/>
            </ListItem>
            <ListItem button>
              <ListItemText primary="Report bugs"/>
            </ListItem>
          </List>
        </Dialog>
          <Toolbar>
            <Typography variant='h6' color='inherit' className={classes.grow}>
              Ruby On Mails
              <Tabs value={value} onChange={this.handleChange1}>
               <Tab label="Inbox" />
               <Tab label="Chat" />
              </Tabs>
            </Typography>
            {auth && (
              <div>
                <IconButton
                  aria-owns={open ? 'menu-appbar' : undefined}
                  aria-haspopup='true'
                  onClick={this.handleMenu}
                  color='inherit'
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
                  <MenuItem onClick={this.handleClose}>Profile</MenuItem>
                  <MenuItem onClick={this.handleClickOpen}>Settings</MenuItem>
                  <MenuItem onClick={this.setRedirect}>Logout</MenuItem>
                </Menu>
              </div>
            )}
          </Toolbar>
        </AppBar>
        {value == true && <this.TabContainer><Inbox /></this.TabContainer>}
        {value == false && <this.TabContainer><Chat /></this.TabContainer>}
      </div>
    );
  }
}

(NavBar as React.ComponentClass<Props>).propTypes = {
  classes: PropTypes.object.isRequired,
} as any;

export default withStyles(styles)(NavBar);
