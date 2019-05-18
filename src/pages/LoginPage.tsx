import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import { withStyles } from '@material-ui/core/styles';
import MenuItem from '@material-ui/core/MenuItem';
import TextField from '@material-ui/core/TextField';

class LoginPage extends React.Component {
  render() {
    return (
      <Card className="login">
      <CardContent>
      <TextField
          id="standard-name"
          label="Name"
          margin="normal"
        />
        <TextField
          id="standard-password"
          label="Password"
          margin="normal"
        />
      </CardContent>
      <CardActions>
        <Button size="small">Learn More</Button>
      </CardActions>
    </Card>
    );
  }
}

export default LoginPage;
