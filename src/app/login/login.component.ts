import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";
import { AuthService, GoogleLoginProvider } from 'angularx-social-login'

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  constructor(private router: Router, private socialAuthService: AuthService){

  }

  public signinWithGoogle(){
    let socialPlatformProvider = GoogleLoginProvider.PROVIDER_ID;

    this.socialAuthService.signIn(socialPlatformProvider)
    .then((userData) => {
      console.log(userData.idToken);
    })
  }

  Submit(){

    this.router.navigate(['/inbox'])
  }

  ngOnInit() {
  }
}
