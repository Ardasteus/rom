import * as React from 'react';
import Input from '@material-ui/core/Input';
import Grid from '@material-ui/core/Grid';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';

class LoginForm extends React.Component {
	render() {
		return (
			<div id='loginform'>
				<Grid container spacing={24} color='#e91e63'>
					<Grid item xs={12}>
						<Input placeholder='Username'></Input>
					</Grid>
					<Grid item xs={12}>
						<Input placeholder='Password'></Input>
					</Grid>
					<Grid item xs={12}>
						<Button color='primary' onClick={() => {window.open('/', '_self'); }}>Login</Button>
					</Grid>
				</Grid>
			</div>
		);
	}
}

export default LoginForm;
