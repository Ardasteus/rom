import * as React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import HomePage from 'pages/HomePage';
import NotFound from 'pages/NotFoundPage';
import LoginPage from 'pages/LoginPage';

class RouterComponent extends React.Component {
  render() {
    return (
      <Router>
        <Switch>
          <Route exact path='/' component={HomePage} />
          <Route exact path='/login' component={LoginPage} />
          <Route component={NotFound} />
        </Switch>
      </Router>
    );
  }
}

export default RouterComponent;
