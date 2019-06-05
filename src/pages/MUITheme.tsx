import { createMuiTheme } from '@material-ui/core/styles';
import MuiThemeProvider from '@material-ui/core/styles/MuiThemeProvider';


const theme = createMuiTheme({
  palette: {
      primary: {
          main: '#000000',
          light: '#ffffff',
      },
      secondary: {
          main: '#b71c1c',
      },
  },
});

export default theme;
