import * as React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import HomePage from 'pages/HomePage';
import NotFound from 'pages/NotFoundPage';
import RegisterPage from 'pages/RegisterPage';
import LoginPage from 'pages/LoginPage';

class RouterComponent extends React.Component {
  render() {
    return (
      <Router>
        <Switch>
          <Route exact path='/' component={LoginPage} />
          <Route exact path='/home' component={HomePage} />
          <Route exact path='/register' component={RegisterPage} />
          <Route component={NotFound} />
        </Switch>
      </Router>
    );
  }
}

export default RouterComponent;
