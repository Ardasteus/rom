import * as React from 'react';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import { IconButton } from '@material-ui/core';
import CloseIcon from '@material-ui/icons/Close';
import Divider from '@material-ui/core/Divider';

interface Props {
  updateShowingMail: (event: any) => void;
}

class ShowMail extends React.Component<Props, {}> {
  constructor(props: Props) {
    super(props);
  }
  /**
   * Set state showingMail, close ShowMail component */ 
  closeMailWrite = () => {
    this.setState({
      showingMail: false,
    });
  }
  render() {
    return (
    <div>
      <Card className='showmail-card'>
          <CardContent>
          <IconButton color='secondary'  aria-label='Close' onClick={this.props.updateShowingMail}>
                <CloseIcon />
          </IconButton>
            <br />
            Sender <br />
            <Divider/>
            Title <br />
            <Divider/>
            Message
          </CardContent>
        </Card>
       </div>
    );
  }
}

export default ShowMail;
