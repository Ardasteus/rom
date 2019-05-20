import * as React from 'react';
import * as reactDOM from 'react-dom';
import LoginForm from 'pages/LoginForm';
import RegisterForm from 'pages/RegisterForm';

class LoginPage extends React.Component {
  

  constructor(props) {
    super(props);
    this.state = {
      isLoginOpen: true,
      isRegisterOpen: false
    };
  }
  

  render() {

    return (
      <div className="root-container">
      {this.state.isLoginOpen && <LoginForm/>}
      {this.state.isRegisterOpen && <RegisterForm/>}
      </div>
    );
  }
}
reactDOM.render(<LoginPage/>, document.getElementById("root"));
export default LoginPage;
