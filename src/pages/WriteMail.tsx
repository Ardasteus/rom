import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';

class WriteMail extends React.Component {
  render() {
    return (
      <Card className='writemail-card'>
          <CardContent>
            <TextField
              variant='filled'
              id='sendTo'
              label='Send to'
              margin='normal'
            />
            <TextField
              variant='filled'
              id='title'
              label='Title'
              margin='normal'
            />
          </CardContent>
        </Card>
    );
  }
}

export default WriteMail;
