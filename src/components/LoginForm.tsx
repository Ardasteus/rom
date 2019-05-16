import * as React from "react";
import Input from '@material-ui/core/Input';
import { withStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';

class LoginForm extends React.Component {
	render() {
		return (
			<div id="loginform">
				<Paper elevation={10} >
					<Input placeholder="Username"></Input>
					<Input placeholder="Password"></Input>
					<Button color="primary" onClick={() => {window.open("/", "_self");}}>Login</Button>
				</Paper>
			</div>
		)
	}
};

export default LoginForm;