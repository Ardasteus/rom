import * as React from 'react';
import { createStyles, withStyles, WithStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';

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
});

export interface Props extends WithStyles<typeof styles> {}

class ToolBarComponent extends React.Component<Props> {
    render() {
        return (
            <div className={this.props.classes.root}>
              <AppBar position='static'>
                <Toolbar>
                  <Typography variant='h6' color='inherit' className={this.props.classes.grow}>
                    Welcome to Ruby on Mails
                  </Typography>
                  <Button color='inherit' onClick={() => {window.open('/login', '_self'); }}>Login</Button>
                </Toolbar>
              </AppBar>
            </div>
          );
    }
}

export default withStyles(styles)(ToolBarComponent);
