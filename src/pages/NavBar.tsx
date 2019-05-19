import * as React from 'react'
import AppBar from '@material-ui/core/AppBar'
import Toolbar from '@material-ui/core/Toolbar'
import Typography from '@material-ui/core/Typography'
import Badge from '@material-ui/core/Badge';
import IconButton from '@material-ui/core/IconButton';
import MailIcon from '@material-ui/icons/Mail';
import NotificationsIcon from '@material-ui/icons/Notifications';
import Button from '@material-ui/core/Button';

const NavBar = () => {
    return(
        <div>
        <AppBar position="static">
            <Toolbar>
                <Typography variant="title" color="inherit">
                Ruby on Mails
                </Typography>
                <Button color="inherit">Inbox</Button>
                <Button color="inherit">Chat</Button>
                <div className="notificationIcons">
                <IconButton color="inherit">
                <Badge badgeContent={0} color="secondary">
                  <MailIcon />
                </Badge>
              </IconButton>
              <IconButton color="inherit">
                <Badge badgeContent={0} color="secondary">
                  <NotificationsIcon />
                </Badge>
              </IconButton>
              </div>
            </Toolbar>
        </AppBar>
        </div>
    )
}
export default NavBar;